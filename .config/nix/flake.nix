{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    utils.url = "github:numtide/flake-utils";

    helix.url = "github:helix-editor/helix";

    niks = {
      url = "github:satoqz/niks";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  } @ inputs:
    utils.lib.eachDefaultSystem (system: let
      inherit (nixpkgs) lib;

      pkgs = import nixpkgs {
        inherit system;
      };

      flakes = builtins.mapAttrs (_: flake: flake.packages.${system}.default) {
        inherit (inputs) helix niks;
      };
    in rec {
      packages.tools = pkgs.buildEnv {
        name = "my-tools";

        paths = with pkgs;
          [
            zsh
            zsh-syntax-highlighting
            zsh-autosuggestions

            coreutils
            util-linux

            htop
            bat
            lsd

            man
            less

            curl
            wget

            ripgrep
            fzf

            flakes.helix
            tmux

            git
            gitui
            gh

            direnv
            nix-direnv

            flakes.niks

            neofetch
          ]
          ++ lib.optionals stdenv.isDarwin [
            docker-client
            docker-compose

            lima-bin
            (colima.override {
              lima = lima-bin;
            })
          ];

        pathsToLink = [
          "/share"
          "/bin"
        ];

        extraOutputsToInstall = [
          "man"
          "doc"
        ];
      };

      packages.default = packages.tools;

      packages.nix-path = pkgs.buildEnv {
        name = "my-nix-path";

        paths = lib.singleton (pkgs.runCommand "nixpkgs-symlink" {} ''
          mkdir -p $out/etc
          ln -s ${nixpkgs} $out/etc/nixpkgs
        '');

        pathsToLink = "/etc/nixpkgs";
      };

      formatter = pkgs.alejandra;

      devShells.default = pkgs.mkShell {
        packages = [
          formatter
          pkgs.nil
        ];
      };
    });

  nixConfig = {
    extra-substituters = [
      "https://systems.cachix.org"
      "https://helix.cachix.org"
    ];
    extra-trusted-public-keys = [
      "systems.cachix.org-1:w+BPDlm25/PkSE0uN9uV6u12PNmSsBuR/HW6R/djZIc="
      "helix.cachix.org-1:ejp9KQpR1FBI2onstMQ34yogDm4OgU2ru6lIwPvuCVs="
    ];
  };
}
