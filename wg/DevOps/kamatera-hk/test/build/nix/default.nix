{ compiler ? "ghc865" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {

              wg =
                haskellPackagesNew.callPackage ./wg.nix { };
            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

  inherit (pkgs) dockerTools stdenv buildEnv writeText;

  wg = pkgs.haskell.packages.${compiler}.wg;

  static-wg = pkgs.haskell.lib.justStaticExecutables pkgs.haskell.packages.${compiler}.wg;

  passwd = ''
    root:x:0:0::/root:/run/current-system/sw/bin/bash
    wg:x:90001:90001::/var/empty:/run/current-system/sw/bin/nologin
  '';

  group = ''
    root:x:0:
    nogroup:x:65534:
    wg:x:90001:wg
  '';

  nsswitch = ''
    hosts: files dns myhostname mymachines
  '';

  wg-conf = ''
    para1 = "$(PARA1)"
    para2 = "$(PARA2)"
  '';

  wg-env = stdenv.mkDerivation {
    name = "wg-env";
    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
      mkdir -p $out/etc/wg
      echo '${wg-conf}' > $out/etc/wg/wg.conf
      echo '${passwd}' > $out/etc/passwd
      echo '${group}' > $out/etc/group
      echo '${nsswitch}' > $out/etc/nsswitch.conf
    '';
  };

  wg-docker =  pkgs.dockerTools.buildImage {
  name = "wg";
  tag = "5.2.0";
  
  contents = [ static-wg
               wg-env ];
  config = {
    Env = [ 
    "PARA1="
    "PARA2="
    ];
    User = "wg";
    Cmd = [ "${static-wg}/bin/wg" "/etc/wg/wg.conf" ];
    ExposedPorts = {
      "5432/tcp" = {};
    };
    WorkingDir = "/data";
    Volumes = {
      "/data" = {};
    };
  };
};
in  {
  inherit wg;
  inherit static-wg;
  inherit wg-docker;
}
