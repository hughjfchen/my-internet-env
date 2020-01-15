{ compiler ? "ghc865" }:

let
  config = {
    packageOverrides = pkgs: rec {
      haskell = pkgs.haskell // {
        packages = pkgs.haskell.packages // {
          "${compiler}" = pkgs.haskell.packages."${compiler}".override {
            overrides = haskellPackagesNew: haskellPackagesOld: rec {

              ss =
                haskellPackagesNew.callPackage ./ss.nix { };
            };
          };
        };
      };
    };
  };

  pkgs = import <nixpkgs> { inherit config; };

  inherit (pkgs) dockerTools stdenv buildEnv writeText;

  ss = pkgs.haskell.packages.${compiler}.ss;

  static-ss = pkgs.haskell.lib.justStaticExecutables pkgs.haskell.packages.${compiler}.ss;

  passwd = ''
    root:x:0:0::/root:/run/current-system/sw/bin/bash
    ss:x:90001:90001::/var/empty:/run/current-system/sw/bin/nologin
  '';

  group = ''
    root:x:0:
    nogroup:x:65534:
    ss:x:90001:ss
  '';

  nsswitch = ''
    hosts: files dns myhostname mymachines
  '';

  ss-conf = ''
    para1 = "$(PARA1)"
    para2 = "$(PARA2)"
  '';

  ss-env = stdenv.mkDerivation {
    name = "ss-env";
    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
      mkdir -p $out/etc/ss
      echo '${ss-conf}' > $out/etc/ss/ss.conf
      echo '${passwd}' > $out/etc/passwd
      echo '${group}' > $out/etc/group
      echo '${nsswitch}' > $out/etc/nsswitch.conf
    '';
  };

  ss-docker =  pkgs.dockerTools.buildImage {
  name = "ss";
  tag = "5.2.0";
  
  contents = [ static-ss
               ss-env ];
  config = {
    Env = [ 
    "PARA1="
    "PARA2="
    ];
    User = "ss";
    Cmd = [ "${static-ss}/bin/ss" "/etc/ss/ss.conf" ];
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
  inherit ss;
  inherit static-ss;
  inherit ss-docker;
}
