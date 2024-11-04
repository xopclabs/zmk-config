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

    # Define keyboard configurations
    keyboards = {
      sweep = {
        board = "nice_nano_v2";
        shield = "cradio";
        split = true;
      };
      corne = {
        board = "nice_nano_v2";
        shield = "corne";
        split = true;
      };
    };

    # Function to create firmware package for a keyboard
    mkKeyboardFirmware = system: name: config:
      let
        builder = if config.split 
          then zmk-nix.legacyPackages.${system}.buildSplitKeyboard
          else zmk-nix.legacyPackages.${system}.buildKeyboard;
        
        shield = if config.split
          then "${config.shield}_%PART%"
          else config.shield;
      in
      builder {
        name = "${name}-firmware";
        inherit (config) board;
        inherit shield;
        src = ./.;
        zephyrDepsHash = "sha256-Y7mY9if+bBIRzlzITzL7HPaqxq6u+1EUmes2fJGaz0U=";
        meta = {
          description = "ZMK firmware for ${name}";
          license = nixpkgs.lib.licenses.mit;
          platforms = nixpkgs.lib.platforms.all;
        };
      };

  in {
    packages = forAllSystems (system: let
      # Generate firmware packages for each keyboard
      firmwarePackages = nixpkgs.lib.mapAttrs (name: config:
        mkKeyboardFirmware system name config
      ) keyboards;

      # Generate flash packages for each keyboard
      flashPackages = nixpkgs.lib.mapAttrs (name: firmware:
        zmk-nix.packages.${system}.flash.override { inherit firmware; }
      ) firmwarePackages;

      # Generate flash package names with -flash suffix
      flashTargets = nixpkgs.lib.mapAttrs' (name: _:
        nixpkgs.lib.nameValuePair 
          "${name}-flash"
          flashPackages.${name}
      ) keyboards;

    in {
      default = firmwarePackages.sweep;
    } // firmwarePackages // flashTargets // {
      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}
