{ inputs, pkgs ? import <nixpkgs> { }, ... }: {
  talhelper = inputs.talhlpr.packages.${pkgs.system}.default;
}
