{
  systemVersion = "26.11";
  username = "nix";
  keymap = "colemak";
  timezone = "Asia/Shanghai";
  wifi = {
    name = "CMCC-H6Rf";
    password = "XUAan4Um";
    address = "192.168.100.166/24";
    gateway = "192.168.100.1";
  };
  nixSubstituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
  ];
}
