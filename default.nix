{
  buildGoModule,
}:
buildGoModule {
  pname = "npdb";
  version = "infinity";
  src = ./.;
  vendorHash = null;
  postPatch = ''
    go mod init npdb
    cat <<EOF >> main.go
    package main
    import "fmt"
    func main() {
    	fmt.Println("hello, cachix")
    }
    EOF
  '';
}
