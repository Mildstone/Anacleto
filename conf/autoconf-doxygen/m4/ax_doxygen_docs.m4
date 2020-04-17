
## ////////////////////////////////////////////////////////////////////////// //
##
## This file is part of the autoconf-bootstrap project.
## Copyright 2018 Andrea Rigoni Garola <andrea.rigoni@igi.cnr.it>.
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
##
## ////////////////////////////////////////////////////////////////////////// //



# DX_REQUIRE_PROG(VARIABLE, PROGRAM)
# ----------------------------------
# Require the specified program to be found for the DX_CURRENT_FEATURE to work.
AC_DEFUN([DX_CHECK_PROG], [
AS_VAR_IF([DX_CURRENT_FEATURE],[yes],[
  AC_PATH_TOOL([$1], [$2], [:])
  AS_VAR_IF([$1],[:],[
	AC_MSG_WARN([$2 not found - doxygen will not DX_CURRENT_DESCRIPTION])
	AS_VAR_IF(DX_CURRENT_FEATURE,[yes],[
	 AS_VAR_SET(DX_CURRENT_FEATURE,[no])
	 AX_KCONFIG_UPDATE(DX_CURRENT_FEATURE)])
  ])
])
])


AC_DEFUN([DX_ARG_ABLE],[
  AC_DEFUN([DX_CURRENT_FEATURE],[DOXYGEN_[]m4_toupper($1)])
  AC_DEFUN([DX_CURRENT_DESCRIPTION],$2)
  $3
  AS_VAR_IF([DX_CURRENT_FEATURE],[yes], $4, $5)
])

AC_DEFUN([DX_TEST_FEATURE],[test x"${DOXYGEN_[]m4_toupper($1)}" = x"yes"])


# DX_INIT_DOXYGEN(PROJECT, [CONFIG-FILE], [OUTPUT-DOC-DIR])
# ---------------------------------------------------------
# PROJECT also serves as the base name for the documentation files.
# The default CONFIG-FILE is "Doxyfile" and OUTPUT-DOC-DIR is "doxygen-doc".
AC_DEFUN([DX_MY_INIT_DOXYGEN], [

  # Files:
  AC_SUBST([DX_PROJECT], [$1])
  AC_SUBST([DX_CONFIG], [ifelse([$2], [], doxygen.cfg, [$2])])
  AC_SUBST([DX_DOCDIR], [ifelse([$3], [], docs, [$3])])
  #
  #
  # Doxygen itself:
  AC_DEFUN([DX_CURRENT_FEATURE],[ENABLE_DOXYGEN])
  #AC_DEFUN([DX_CURRENT_DESCRIPTION],[generate any documentation])
  DX_CHECK_PROG([DX_PERL], perl)
  AC_SUBST([PERL_PATH], ${DX_PERL})
  #DX_ARG_ABLE(doc, [generate any documentation],
			#[DX_CHECK_PROG([DX_PERL], perl)],
			#[AC_SUBST([PERL_PATH], ${DX_PERL})])
  #
  # Dot for graphics:
  DX_ARG_ABLE(dot, [generate graphics],
			[DX_CHECK_PROG([DX_DOT], dot)],
			[AC_SUBST([HAVE_DOT], [YES])
			 AC_SUBST([DOT_PATH], [$(dirname ${DX_DOT})])],
			[AC_SUBST([HAVE_DOT], [NO])])
  #
  # Man pages generation:
  DX_ARG_ABLE(man, [generate manual pages],
			[],
			[AC_SUBST([GENERATE_MAN], [YES])],
			[AC_SUBST([GENERATE_MAN], [NO])])
  #
  # RTF file generation:
  DX_ARG_ABLE(rtf, [generate RTF documentation],
			[],
			[AC_SUBST([GENERATE_RTF], [YES])],
			[AC_SUBST([GENERATE_RTF], [NO])])
  # XML file generation:
  DX_ARG_ABLE(xml, [generate XML documentation],
			[],
			[AC_SUBST([GENERATE_XML], [YES])],
			[AC_SUBST([GENERATE_XML], [NO])])
  # (Compressed) HTML help generation:
  DX_ARG_ABLE(chm, [generate compressed HTML help documentation],
			[DX_CHECK_PROG([DX_HHC], hhc)],
			[AC_SUBST([HHC_PATH], ${DX_HHC})
			 AC_SUBST([GENERATE_HTML], [YES])
			 AC_SUBST([GENERATE_HTMLHELP], [YES])],
			[AC_SUBST([GENERATE_HTMLHELP], [NO])])
  # Seperate CHI file generation.
  DX_ARG_ABLE(chi, [generate seperate compressed HTML help index file],
			[],
			[AC_SUBST([GENERATE_CHI], [YES])],
			[AC_SUBST([GENERATE_CHI], [NO])])
  # Plain HTML pages generation:
  DX_ARG_ABLE(html, [generate plain HTML documentation],
			[],
			[AC_SUBST([GENERATE_HTML], [YES])],
			[AC_SUBST([GENERATE_HTML], [NO])])
  # PostScript file generation:
  DX_ARG_ABLE(ps, [generate PostScript documentation],
			[DX_CHECK_PROG([DX_LATEX], latex)
			 DX_CHECK_PROG([DX_MAKEINDEX], makeindex)
			 DX_CHECK_PROG([DX_DVIPS], dvips)
			 DX_CHECK_PROG([DX_EGREP], egrep)])
  # PDF file generation:
  DX_ARG_ABLE(pdf, [generate PDF documentation],
			[DX_CHECK_PROG([DX_PDFLATEX], pdflatex)
			 DX_CHECK_PROG([DX_MAKEINDEX], makeindex)
			 DX_CHECK_PROG([DX_EGREP], egrep)])
  # LaTeX generation for PS and/or PDF:
  if DX_TEST_FEATURE(ps) || DX_TEST_FEATURE(pdf); then
	AC_SUBST(GENERATE_LATEX, YES)
  else
	AC_SUBST(GENERATE_LATEX, NO)
  fi

# Paper size for PS and/or PDF:
AC_ARG_VAR(DOXYGEN_PAPER_SIZE,
		   [a4wide (default), a4, letter, legal or executive])
case "$DOXYGEN_PAPER_SIZE" in
#(
"")
	AC_SUBST(DOXYGEN_PAPER_SIZE, "")
;; #(
a4wide|a4|letter|legal|executive)
	AC_SUBST(PAPER_SIZE, $DOXYGEN_PAPER_SIZE)
;; #(
*)
	AC_MSG_ERROR([unknown DOXYGEN_PAPER_SIZE='$DOXYGEN_PAPER_SIZE'])
;;
esac

])
