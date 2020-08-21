SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "MIT"

inherit logging 

python do_compile() {
    bb.plain("***********************************************");
    bb.plain("*                                             *");
    bb.plain("*  Python do compile                          *");
    bb.plain("*                                             *");
    bb.plain("***********************************************");
}
