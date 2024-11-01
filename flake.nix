{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: rec {
      default = firmware;

      firmware = zmk-nix.legacyPackages.${system}.buildSplitKeyboard {
        name = "sweep-firmware";

        src = nixpkgs.lib.sourceFilesBySuffices self [ 
            ".conf" ".keymap" ".dtsi" ".yml" ".shield" ".overlay" ".defconfig" 
        ];

        board = "nice_nano_v2";
        shield = "cradio_%PART%";
        extraWestBuildFlags = [ "-S zmk-usb-logging" ];

        zephyrDepsHash = "sha256-/VaKrYv45ErPQJjYVlsEgnN/58Z5xeHdlsi/KmDVOQg=";

        meta = {
          description = "ZMK firmware";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

      flash = zmk-nix.packages.${system}.flash.override { inherit firmware; };
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
