#
# TAGS DEFINED IN CONFIG FILE
#

# PROJECT_NAME           = $(DX_TITLE)
# PROJECT_BRIEF          = $(DX_BRIEF)

# PROJECT_LOGO           = $(DX_LOGO)
# IMAGE_PATH             = $(DX_IMGDIR)
# LAYOUT_FILE            = $(DX_LAYOUT)
# INPUT                  = $(DX_INPUT)
# EXCLUDE                = $(DX_EXCLUDE_PAGES)
# HTML_HEADER            = $(DX_HTML_HEADER)
# HTML_FOOTER            = $(DX_HTML_FOOTER)
# HTML_EXTRA_STYLESHEET  = $(DX_HTML_STYLESHEET)
# CHM_FILE               = $(DX_CHMFILE)
# SEARCHDATA_FILE        = $(DX_SEARCHFILE)
# EXTRA_SEARCH_MAPPINGS  = $(DX_TAGFILES)
# TAGFILES               = $(DX_TAGFILES)
# GENERATE_TAGFILE       = $(DX_DESTTAG)
# project
DX_TITLE  ?= Project title
DX_BRIEF  ?= project code documentation reference
DX_PACKAGE_NAME ?= maindoc
DX_CFG         ?= $(top_srcdir)/conf/autoconf-doxygen/config/doxygen.cfg

# directories
DX_DESTDIR     ?= $(builddir)
DX_TAGDIR      ?= $(top_builddir)/conf/dxtags
DX_DESTTAG     ?= ${DX_TAGDIR}/${DX_PACKAGE_NAME}.tag
DX_SEARCHFILE  ?= ${DX_TAGDIR}/${DX_PACKAGE_NAME}.xml
DX_CHMFILE     ?= ${DX_TAGDIR}/${DX_PACKAGE_NAME}.chm


# style
DX_LOGO        ?= $(top_srcdir)/conf/autoconf-doxygen/config/style/logo.jpg
DX_LAYOUT      ?= $(top_srcdir)/conf/autoconf-doxygen/config/general_layout.xml
DX_IMGDIR      ?= img

# input default
DX_INPUT         ?=
DX_EXCLUDE_PAGES ?=

export DX_TITLE DX_BRIEF DX_LOGO DX_DESTDIR DX_LAYOUT DX_INPUT \
	   DX_INPUT DX_EXCLUDE_PAGES DX_IMAGE_PATH DX_HTML_HEADER  \
	   DX_HTML_FOOTER DX_HTML_STYLESHEET DX_CHMFILE DX_SEARCHFILE \
	   DX_TAGFILES DX_DESTTAG DOXYGEN_PAPER_SIZE

export DX_PERL HAVE_DOT DOT_PATH DX_HHC HHC_PATH DX_LATEX DX_MAKEINDEX \
	   DX_DVIPS DX_EGREP

export GENERATE_MAN GENERATE_RTF GENERATE_XML GENERATE_HTML GENERATE_HTMLHELP \
	   GENERATE_CHI GENERATE_LATEX

DX_OUTPUT_DIRS = $(DX_TAGDIR)
$(DX_OUTPUT_DIRS):
	@ $(MKDIR_P) $@

doxygen-%: DX_INPUT:="$(addprefix $(srcdir)/,$(DX_INPUT))"
doxygen-%: $(DX_TAGDIR)
	@ $(info generating doxygen documentation) \
	  $(DOXYGEN_BINARY) $(DX_CFG); \
	  echo $${DX_INPUT}

$(DX_DESTDIR)/latex: doxygen-latex
$(DX_DESTDIR)/html: doxygen-html

$(DX_DESTDIR)/latex/refman.pdf: $(DX_DESTDIR)/latex
	$(MAKE) -C $(DX_DESTDIR)/latex refman.pdf

${DX_DESTDIR}/${DX_PACKAGE_NAME}.pdf: $(DX_DESTDIR)/latex/refman.pdf
	cp $< $@

html:  ##@docs generate html documentation
html:  $(DX_DESTDIR)/html
latex: ##@docs generate latex documentation
latex: $(DX_DESTDIR)/latex
pdf:   ##@docs generate pdf manual
pdf:   $(DX_DESTDIR)/${DX_PACKAGE_NAME}.pdf

clean-local:
	@ rm -rf doxygen.stamp html latex \
	  $(DX_DESTDIR)/${DX_PACKAGE_NAME}.pdf



