{

  description = "Subminer Nix Flake";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-26.05";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system} = {
        subminer = pkgs.callPackage ./subminer.nix {};
        default = self.packages.${system}.subminer;
      };
    };

}
