{
  description = "This flake describes my personal systems configurations.";

  inputs = {
    stable.url = "github:NixOs/nixpkgs/nixos-25.05";
    stableHome.url = "github:nix-community/home-manager/release-25.05";
    stableHome.inputs.nixpkgs.follows = "stable";
    # unstable.url = "github:NixOs/nixpkgs/nixos-unstable";
    # unstableHome.url = "github:nix-community/home-manager/master";
    # unstableHome.inputs.nixpkgs.follows = "unstable";
    user.url = "/etc/nixos/user";
  };

  outputs =
    {
      self,
      stable,
      stableHome,
      # unstable,
      # unstableHome,
      user,
    }:
    let
      system = "x86_64-linux";
      nixpkgs =
        {
          "stable" = stable;
          # "unstable" = unstable;
        }
        ."${user.nixosVersion}";
      home-manager =
        {
          "stable" = stableHome;
          # "unstable" = unstableHome;
        }
        ."${user.nixosVersion}";
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
