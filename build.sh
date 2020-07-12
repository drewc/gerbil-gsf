#!/usr/bin/env bash
export PKG_CONFIG_PATH=$(nix-shell -p libgsf pkgconfig mount libselinux libsepol \
                           --run 'echo $PKG_CONFIG_PATH')

compile_gsf () {
gxc  -cc-options "`pkg-config --cflags libgsf-1`"\
     -ld-options "`pkg-config --libs libgsf-1`" "$1";
 return 0;
}

compile_gsf glib.ss;
compile_gsf infile.ss;
compile_gsf input.ss;
compile_gsf gsf.ss;
