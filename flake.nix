{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";

    talhlpr.url = "github:budimanjojo/talhelper";
    talhlpr.inputs.nixpkgs.follows = "unstable";

    parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { ... } @ inputs:
    let
      genPkgs = system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues (import ./overlays.nix {inherit inputs;});
        };
    in
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = inputs.nixpkgs.lib.systems.flakeExposed;

      imports = [inputs.devshell.flakeModule];

      perSystem = {inputs', self', pkgs, system, ...}: {
        _module.args.pkgs = genPkgs system;
        devShells.default = pkgs.devshell.mkShell {
          imports = [(pkgs.devshell.importTOML ./devshell.toml)];
        };
      };
    };
}
