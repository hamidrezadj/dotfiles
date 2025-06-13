{
  description = "This flake describes my personal systems configurations.";

  inputs = {
    nixpkgs.url = "github:NixOs/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "stable";
    user.url = "/etc/nixos/user";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      user,
    }:
    let
      system = "x86_64-linux";
      borna-fonts-src = {
        url = "http://www.bornaray.com/Content/downloads/bfonts.zip";
        hash = "sha256-nwD00FL6DHkkCok0p3U7g+Ub93Tr8ByJnc5rmWgfLew=";
      };
    in
    {
      nixosConfigurations.${user.hostName} = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit user;
          inherit borna-fonts-src;
        };
        modules = [
          home-manager.nixosModules.home-manager
          ./configuration.nix
        ];
      };
    };
}
