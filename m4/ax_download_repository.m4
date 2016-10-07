
# AX_DOWNLOAD_TAR([URL],[DEST_DIR],[DL_TMP])
# ----------------
AC_DEFUN([AX_DOWNLOAD_TAR],[
  m4_pushdef([_tmp],[m4_default($3,tmp})])
  m4_pushdef([_url],$1)
  AC_PROG_MKDIR_P
  AC_PROG_SED
  AC_CHECK_PROGS([CURL],[curl])
  AC_CHECK_PROGS([TAR],[gtar tar])
  AC_CHECK_PROGS([UNIQ],[uniq])
  AC_CHECK_PROGS([WC],[wc])
  $MKDIR_P _tmp
  $MKDIR_P $2
  AS_VAR_SET([_tar],_tmp[]/$(echo _url | sed -e "s|.*/||"))
  AS_ECHO("Downloading $_tar from $1")
  AS_IF([test -f $_tar],,[$CURL -SL _url > $_tar])
  AS_IF([test $($TAR -tzf $_tar | $SED -e "s|/.*||" | $UNIQ | $WC -l) = 1],
	[$TAR -xzf $_tar -C $2 --strip 1],
	[$TAR -xzf $_tar -C $2])
  m4_popdef([_url])
  m4_popdef([_tmp])
])
