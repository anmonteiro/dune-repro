{
  description = "Dune + codesign repro";

  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}".extend (self: super: {
          ocamlPackages = super.ocaml-ng.ocamlPackages_4_14.overrideScope'
            (oself: osuper: {
              dune = oself.dune_3;
              dune_2 = oself.dune_3;
              dune_3 = osuper.dune_3.overrideAttrs (o: {
                src = builtins.fetchurl {
                  url = https://github.com/ocaml/dune/releases/download/3.5.0/dune-3.5.0.tbz;
                  sha256 = "041n16sn41wwj6fgi7l10hvbl5x5swygqv33d4csx7rm0iklrgbp";
                };
                nativeBuildInputs = o.nativeBuildInputs ++ [ pkgs.makeWrapper ];
                postFixup =
                  if super.stdenv.isDarwin then ''
                    wrapProgram $out/bin/dune \
                      --suffix PATH : "${super.darwin.sigtool}/bin"
                  '' else "";
              });
            });
        });
      in
      {
        packages.default = with pkgs.ocamlPackages; buildDunePackage {
          pname = "repro";
          version = "n/a";
          src = ./.;
          propagatedBuildInputs = [ dune-site ];
        };
        legacyPackages = pkgs;
      });
}
