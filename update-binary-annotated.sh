#!/sbin/sh
# Full-fledged Linux installer for NABU by kumar_jy

# ── Recovery 通信协议 ──────────────────────────────────
# Android Recovery 调用 update-binary 时传 3 个参数:
#   $1 = 父进程 fd (用于退出码)
#   $2 = 输出 fd (写 "ui_print" 消息回 Recovery UI)
#   $3 = ZIP 包绝对路径
OUTFD=/proc/self/fd/$2 # 打开输出 fd，往这个文件写 `ui_print` 消息
ZIPFILE="$3"           # 保存 ZIP 包路径

# ── 打印函数 ───────────────────────────────────────────
ui_print() {
	if $BOOTMODE; then # Magisk 模式(前台):  直接 stdout
		echo "$1"
	else # Recovery 模式(后台): 按 Recovery 协议格式写入 fd
		echo -e "ui_print $1\nui_print" >>$OUTFD
	fi
}

# ── 错误退出 ───────────────────────────────────────────
abort() {
	ui_print " "                                   # 空行分隔
	ui_print "$1"                                  # 打印错误消息
	umount -lf "$esp_part" "$win_part" 2>/dev/null # 清理: 强制卸载 esp 和 win
	exit 1
}

# ── 检测运行环境 ───────────────────────────────────────
# Magisk 在 Android 用户空间运行，zygote 进程存在;
# TWRP/Recovery 是独立 Linux 环境，无 zygote.
BOOTMODE=false                                                                          # 先默认 false (Recovery)
ps | grep zygote | grep -v grep >/dev/null && BOOTMODE=true                             # 标准 ps 查 zygote
$BOOTMODE || ps -A 2>/dev/null | grep zygote | grep -v grep >/dev/null && BOOTMODE=true # 兼容 busybox ps -A

# ── 工作目录 ────────────────────────────────────────────
# /dev/tmp 在 Magisk 和 Recovery 下都是 tmpfs，可读写
tmp=/dev/tmp/install
rm -rf "$tmp"   # 清理上次残留
mkdir -p "$tmp" # 建目录

# ── 分区路径定义 ────────────────────────────────────────
# NABU (Xiaomi Pad 5) 使用 GPT 分区表 + A/B slot 布局
boot_part=/dev/block/bootdevice/by-name/boot # Android boot 分区 (含 slot 后缀，如 boot_a)
part=/dev/block/by-name                      # 分区别名目录的基路径
esp_part=$part/esp                           # EFI System Partition (存储 UEFI bootloader/grub)
win_part=$part/win                           # Windows 分区 (NTFS, 双启动场景)
linux_part=$part/linux                       # Linux rootfs 分区 (目标: 写入 Arch Linux)
cust_part=$part/cust                         # cust 分区 (复用: 存放 boot.img)

# ── 工具路径 ────────────────────────────────────────────
zext="$tmp/bin/7zzs"                  # 7-Zip 静态二进制 (解压 rootfs.img)
mke2fs="$tmp/bin/mke2fs"              # ext4 格式化工具
mkfs.fat="$tmp/bin/mkfs.fat"          # FAT32 格式化工具
bcdctl="$tmp/bin/bcdctl"              # Windows BCD 编辑工具 (检测 Secure Boot)
BCD="$tmp/esp/EFI/Microsoft/Boot/BCD" # Windows 启动配置数据库路径

# ── 解压工具链 ──────────────────────────────────────────
# 从 ZIP 中提取 bin/ 目录 (包含 7zzs, mke2fs, mkfs.fat, bcdctl 等)
unzip -o "$ZIPFILE" "bin/*" -d "$tmp" || abort "Failed to extract bin"
chmod -R 0777 "$tmp" # 全部设为可执行

# ════════════════════════════════════════════════════════
#  阶段 1：刷写 Linux rootfs
# ════════════════════════════════════════════════════════

ui_print "---------------------------------------------"
ui_print "              Linux installation             "
ui_print "---------------------------------------------"
ui_print " "

# 检查 linux 分区设备节点是否存在
ui_print "Checking linux partition device: $linux_part"
if [ ! -e "$linux_part" ]; then
	abort "Linux partition device not found: $linux_part" # 不存在则终止
fi

# 若已挂载则强制卸载，防止写入冲突
if mount | grep -q " $linux_part "; then
	ui_print "Linux partition $linux_part is mounted, unmounting..."
	umount -lf "$linux_part" || abort "Failed to unmount linux partition $linux_part"
fi

# 确保块设备可写 (有些 ROM 默认只读)
blockdev --setrw "$linux_part"

ui_print "Formatting and flashing Linux image"

# 格式化为 ext4
$mke2fs -t ext4 -F "$linux_part" || abort "Failed to format linux partition"

# 流式解压 rootfs.img 直写分区
# 7zzs e -so: extract to stdout;  stdout 重定向到分区设备
# 这样无需在 tmpfs 中缓存整个镜像（rootfs 通常 ~4-8GB）
$zext e -so "$ZIPFILE" "images/rootfs.img" >"$linux_part" 2>"$tmp/7z.err" ||
	abort "Failed to dump rootfs image"

ui_print " "
ui_print "Done flashing rootfs!"

# ════════════════════════════════════════════════════════
#  阶段 2：ESP 引导配置
# ════════════════════════════════════════════════════════

ui_print "---------------------------------------------"
ui_print "             Boot Configuration              "
ui_print "---------------------------------------------"
ui_print " "

mkdir -p "$tmp/esp" # 挂载点

# 若 ESP 已挂载则先卸载
if mount | grep -q "$esp_part"; then
	ui_print "ESP partition is already mounted, forcing unmount..."
	umount -lf "$esp_part" || abort "Failed to unmount the ESP partition"
fi
mount "$esp_part" "$tmp/esp" || abort "Failed to mount ESP partition"

# ── 判断 Secure Boot 状态 ──────────────────────────────
# 检查 ESP 中是否存在 BCD 文件且未启用 testsigning
# Windows Secure Boot 启用时，BCD 中不会含 "testsigning" 标志
ui_print "Verifying present bootloader configration"
if [ -f $BCD ] && ! $bcdctl --check $BCD 2>/dev/null | grep -q "testsigning"; then

	# ── 分支 A: Secure Boot 已启用 ──────────────────────
	# 策略: 用 WinPE 镜像覆盖 ESP → 重启后 WinPE 自动执行禁用 Secure Boot → 用户二次刷入走正常路径
	ui_print "Secure Boot configuration detected. Proceeding to disable Secure Boot."

	umount -lf "$win_part" 2>/dev/null # 清理 Windows 挂载
	mkdir -p "$tmp/win" && mount.ntfs "$win_part" "$tmp/win" ||
		abort "Failed to mount Windows"  # 挂载 NTFS 分区
	mkdir -p "$tmp/win/installer/efi" # 目标目录
	unzip -o "$ZIPFILE" "installer/*" -d "$tmp/win" ||
		abort "Failed to extract installer files" # 解压 WinPE 相关文件到 Windows
	unzip -o "$ZIPFILE" "efi/*" -d "$tmp/win/installer" ||
		abort "Failed to extract installer into Windows" # 同时解压 efi 供 WinPE 使用

	# ⚠️ BUG 点: 备份顺序错误
	umount -lf "$esp_part" && $mkfs.fat -F32 -s1 "$esp_part" -n ESPNABU 2>/dev/null # 先格式化擦除了 ESP
	dd if="$esp_part" of=/sdcard/esp_backup.img bs=64M ||
		abort "Failed to backup esp image" # ← 备份是空 ESP，原数据已丢

	dd if="$tmp/win/installer/pe.img" of="$esp_part" bs=64M ||
		abort "Failed to dump pe image" # 写入 WinPE → 重启后从 WinPE 引导

else

	# ── 分支 B: Secure Boot 已禁用 ───────────────────────
	ui_print "Un-secure boot configration found"

	# 删除 ESP/EFI/ 下除了 Microsoft 的所有目录（保留 Windows Boot Manager）
	for i in "$tmp"/esp/[eE][fF][iI]/*; do
		[ -e "$i" ] || continue                  # 跳过不存在的
		case ${i##*/} in                         # 取目录名
		[mM][iI][cC][rR][oO][sS][oO][fF][tT]) ;; # Microsoft → 保留
		*) rm -rf -- "$i" ;;                     # 其他 → 删除
		esac
	done

	mkdir -p "$tmp/esp/EFI" # 确保 EFI 目录存在
	unzip -o "$ZIPFILE" "efi/*" -d "$tmp/esp" ||
		abort "Failed to extract efi" # 解压 Linux EFI 启动文件
fi

# ── 可选: 刷写 boot.img 到 cust 分区 ──────────────────
# 某些设备需要独立的 kernel 映像；NABU 通常不需要
unzip -o "$ZIPFILE" "images/boot.img" -d "$tmp" 2>/dev/null
if [ ! -f "$tmp/images/boot.img" ]; then
	ui_print "No separate boot.img found, skipping..."
else
	umount -lf "$cust_part" 2>/dev/null
	"$mke2fs" -t ext4 -F "$cust_part" || abort "Failed to format cust partition"
	dd if="$tmp/images/boot.img" of="$cust_part" ||
		abort "Failed to flash boot.img to cust partition!"
fi

# 卸载 ESP 和 Windows 分区
umount -lf "$esp_part" "$win_part" 2>/dev/null
ui_print " "
ui_print "Boot configuration setup completed!"

# ════════════════════════════════════════════════════════
#  阶段 3: DBKP — UEFI 注入到 Android Boot 分区
# ════════════════════════════════════════════════════════

ui_print "---------------------------------------------"
ui_print "           DBKP UEFI installation            "
ui_print "---------------------------------------------"
ui_print " "

# 基于 topjohnwu/osm0sis/Dees_Troy 的 A/B 刷写方案
target=$boot_part # boot 分区基路径 (不含 slot 后缀)

name=$(basename $target) # 提取分区名: "boot"

ui_print "Unpacking the DBKP installer..."

# 解压 DBKP 目录 (含 UEFI payload、配置、shellcode、magiskboot、DualBootKernelPatcher)
unzip -o "$ZIPFILE" "DBKP/*" -d "$tmp" || abort "Failed to extract DBKP!"

cd "$tmp/DBKP"

# 查找三个必要文件
uefipayload=$( (ls *_EFI.fd) 2>/dev/null)      # UEFI 固件 payload
dbkpcfg=$( (ls DualBoot.*.cfg) 2>/dev/null)    # DualBoot 配置
shellcode=$( (ls ShellCode.*.bin) 2>/dev/null) # Kernel 注入 shellcode

[ "$uefipayload" ] || abort "No UEFI payload found in zip!"
[ "$dbkpcfg" ] || abort "No DBKP config found in zip!"
[ "$shellcode" ] || abort "No DBKP shellcode found in zip!"

tool="$tmp/DBKP/magiskboot"               # Android boot.img 解包/重打包工具
patcher="$tmp/DBKP/DualBootKernelPatcher" # 内核注入工具
chmod 755 "$tool"
chmod 755 "$patcher"

backuppath="/sdcard/boot_backup" # 备份目标路径 (用户可访问)

# 获取当前 A/B slot: 返回 "_a" 或 "_b"
# getprop 只在 Android 用户空间有效; Recovery 下可能为空
slot=$(getprop ro.boot.slot_suffix)

ui_print " "
ui_print "Current slot: $slot."

# ⚠️ slot 非空检查被注释掉，即使 slot 为空也继续执行
# 对非 A/B 设备: slot=""，target$slot = boot，操作直接针对 boot 分区
# 对 A/B 设备: slot="_a" 或 "_b"
# if [ "$slot" ]; then
if [ "$uefipayload" ]; then
	ui_print "Running image patcher on $name$slot..."

	# 导出当前 boot 分区到文件
	dd if="$target$slot" of=boot.img || abort "Failed to dump image!"

	# 备份原始 boot 到 /sdcard/boot_backup/
	ui_print "Backing up original boot$slot.img..."
	rm -f "$backuppath$slot.img"
	cp -f boot.img "$backuppath$slot.img"
	ui_print "Original boot$slot backed up to $backuppath$slot.img!"

	# magiskboot 解包 boot.img:
	#   -h 表示保留头部信息
	#   解出: kernel, kernel_dtb, ramdisk.cpio, second, dtb, dtbo 等
	$tool unpack -h boot.img || abort "Failed to unpack image!"

	# DualBootKernelPatcher 核心操作:
	#   读取 kernel → 注入 UEFI payload + DualBoot 配置 + shellcode
	#   shellcode 在启动时先于 Android 内核执行，加载 UEFI 并显示双启动菜单
	#   输出 patchedKernel
	$patcher kernel $uefipayload patchedKernel $dbkpcfg $shellcode ||
		abort "Failed to patch the kernel"

	mv patchedKernel kernel # 替换原 kernel 为打过补丁的版本

	# magiskboot repack:
	#   将修改后的 kernel + 原始 ramdisk/dtb 等重新打包为 new-boot.img
	$tool repack boot.img || abort "Failed to repack image!"
	$tool cleanup # 清理解包临时文件
fi
# else
#   ui_print "Failed to get current slot!";
#   abort "Exiting...";
# fi;

# 刷写 new-boot.img 到 boot 分区
blockdev --setrw "$target$slot" # 确保可写

# cat new-boot.img /dev/zero > partition 技巧:
#   先写入 new-boot.img 内容，再用 /dev/zero 填充剩余空间
#   确保整个分区被填满，防止残留旧数据导致 boot 异常
#   2>/dev/null 忽略 "设备空间不足" 错误（填充到分区末尾自然报错）
#   || true 确保即使填充阶段报错也视为成功
cat new-boot.img /dev/zero >"$target$slot" 2>/dev/null || true

rm -f new-boot.img # 清理

if [ "$uefipayload" ]; then
	ui_print " "
	ui_print "Image patching complete!"
fi

ui_print " "
ui_print "Done flashing EFI!"
