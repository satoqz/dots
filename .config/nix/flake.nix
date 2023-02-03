{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      inherit (nixpkgs) lib;
      pkgs = import nixpkgs {
        inherit system;
      };
    in rec {
      packages.env = pkgs.buildEnv {
        name = "my-environment";

        paths = with pkgs; [
          zsh
          zsh-syntax-highlighting
          zsh-autosuggestions

          coreutils
          util-linux
          man
          less
          bat
          curl
          wget
          htop
          lsd
          fzf
          ripgrep
          neofetch          

          helix
          tmux

          git
          gitui
          gh

          direnv
          nix-direnv
        ] ++ lib.optionals stdenv.isDarwin [
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

      packages.default = packages.env;

      formatter = pkgs.alejandra;

      devShells.default = pkgs.mkShell {
        packages = [
          formatter
          pkgs.nil
        ];
      };
    });
}
