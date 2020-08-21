SUMMARY = "bitbake-layers recipe"
DESCRIPTION = "Recipe created by bitbake-layers"
LICENSE = "MIT"

INHERIT += "logging"
INHERIT += "externalsrc"

## EXTERNAL SOURCES ##
EXTERNALSRC       = "${abs_top_srcdir}/src/hello_cpp"
EXTERNALSRC_BUILD = "${abs_top_builddir}/src/hello_cpp"

SRC_URI += "file://${EXTERNALSRC}/hello.cpp"

## not needed if we use Anacleto one
## LIC_FILES_CHKSUM = "file://${EXTERNALSRC}/hello.cpp;md5=d28a48395f80a24b0bd75519192addb9"

## Always keep the same project revision so bitbake checks for src changes
PR = "0"

do_clean() {
    make -C ${EXTERNALSRC_BUILD} clean
}

do_compile() {
    bbplain "***********************************************";
    bbplain "*                                             *";
    bbplain "*  COMPILING EXTERNAL HELLO  ...              *";
    bbplain "*                                             *";
    bbplain "***********************************************";

    bbplain "EXTERNALSRC       = ${EXTERNALSRC}        ";
    bbplain "EXTERNALSRC_BUILD = ${EXTERNALSRC_BUILD}  ";

    make -C ${EXTERNALSRC_BUILD} all
}

do_install() {
    bbplain " INSTALL: hello ";
    # make -C ${EXTERNALSRC_BUILD} install
    mkdir -p ${D}/usr/bin
    cp -av ${EXTERNALSRC_BUILD}/hello ${D}/usr/bin
}





