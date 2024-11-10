{
  inputs = {
    nixpkgs.url = "nixpkgs";
    unstable.url = "unstable";
    parts.url = "flake-parts";

    devshell.url = "devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    talhlpr.url = "github:budimanjojo/talhelper";
    talhlpr.inputs.nixpkgs.follows = "unstable";
  };

  outputs = { ... } @ inputs:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [ inputs.devshell.flakeModule ];

      perSystem = { pkgs, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.devshell.overlays.default
            (final: _: {
              talhelper = inputs.talhlpr.packages.${system}.default;
            })
            (final: _: {
              unstable = import inputs.unstable {
                inherit (final) system;
                overlays = [
                  (final: prev: {
                    kubernetes-helm-wrapped = prev.wrapHelm prev.kubernetes-helm {
                      plugins = with prev.kubernetes-helmPlugins; [
                        helm-diff
                        helm-git
                        helm-unittest
                      ];
                    };
                  })
                ];
              };
            })
          ];
        };

        devShells.default = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
        };
      };
    };
}
