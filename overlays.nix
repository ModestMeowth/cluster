{ inputs, ... }: {
  unstable-packages = final: prev: {
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
  };

  additions = final: _:
    import ./packages.nix {
      inherit inputs;
      pkgs = final;
    };

  devshell = inputs.devshell.overlays.default;
}
