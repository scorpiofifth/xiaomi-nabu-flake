# Arch Linux Installer for Xiaomi Pad 5 (Nabu)

GitHub Actions 自动构建的 Arch Linux 安装包，适用于 Xiaomi Mi Pad 5 (nabu)。

## 文件结构

```
arch-nabu-installer.zip
│
├── images/
│   ├── rootfs.img       # 20G ext4, Arch Linux ARM 根文件系统
│   └── esp.img          # 250M FAT32, EFI 系统分区 (rEFInd + UKI)
│
├── efi/                 # ESP 的 EFI/ 目录内容
│   ├── android/
│   │   └── AndroidBootPkg.efi    # rEFInd 菜单中"重启到 Android"
│   ├── BOOT/
│   │   ├── bootaa64.efi          # rEFInd 启动管理器
│   │   ├── fbaa64.efi            # EFI 文件浏览器
│   │   ├── refind.conf           # rEFInd 配置
│   │   ├── drivers_aa64/
│   │   │   └── GopRotate_aa64.efi # 竖屏旋转驱动
│   │   ├── themes/               # rEFInd 主题
│   │   ├── icons/
│   │   └── vars/
│   └── arch/
│       └── arch-linux-nabu.efi   # Unified Kernel Image
│
├── installer/
│   ├── install.bat               # Windows PE 安装脚本
│   └── pe.img                    # WinPE 映像
│
├── flash-linux.bat               # fastboot 刷写脚本 (Windows)
├── flash-linux.sh                # fastboot 刷写脚本 (Linux)
│
├── bin/                          # 跨平台预编译工具
│   ├── 7zzs                      # 7-Zip
│   ├── bcdctl                    # Windows BCD 编辑器
│   ├── btrfs                     # Btrfs 工具
│   ├── mke2fs                    # ext2/3/4 格式化
│   └── mkfs.fat                  # FAT32 格式化
│
├── DBKP/                         # DualBootKernelPatcher 双启动工具
│   ├── DualBootKernelPatcher     # ARM64 内核修补器
│   ├── DualBoot.Sm8150.cfg       # 配置 (栈基址/大小)
│   ├── ShellCode.NabuPStore.bin  # 启动选择 ShellCode
│   ├── SM8150_EFI.fd             # UEFI 固件
│   ├── magiskboot                # boot.img 解包/重打包
│   └── README.md
│
└── META-INF/com/google/android/  # TWRP/Magisk 刷机包结构 (预留)
    ├── updater-script
    └── update-binary
```

## 构建流程

GitHub Actions (`.github/workflows/build-installers.yml`) 在 `ubuntu-24.04-arm` 上执行：

1. **准备根文件系统** — 创建 20G ext4 镜像并挂载
2. **解压 Arch Linux ARM rootfs** — 使用 alpine Docker 容器中的 bsdtar
3. **arch-chroot 内配置系统** — 初始化 pacman 密钥、设置 locale、添加 nabu 仓库、安装内核/驱动/服务/固件
4. **应用 overlay** — 复制 `base/overlay/` 中的 systemd 服务、UKI 预设、cmdline 配置、rEFInd 模板等
5. **生成 UKI** — `mkinitcpio -P` 创建 Unified Kernel Image
6. **打包 efi** — 导出 ESP 内容到 `efi/` 目录
7. **创建 ESP 镜像** — 250M FAT32 格式，填充 efi 内容
8. **收集工具** — 复制 `bin/`、`DBKP/`、`installer/`、`META-INF/`
9. **下载 WinPE** — 用于 Windows 双启动安装
10. **上传 artifact** — 打包为 `arch-nabu-installer`

## 刷写方法

### fastboot (推荐)

```bash
# Linux
chmod +x flash-linux.sh && ./flash-linux.sh

# Windows
flash-linux.bat
```

### Windows PE

1. 将 `installer/` 目录复制到 Windows 分区
2. 运行 `install.bat`

### 双启动

使用 `DBKP/` 中的工具修补 Android 的 boot.img，实现 Android ↔ Arch Linux 双启动。
