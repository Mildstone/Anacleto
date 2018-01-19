#
# TAGS DEFINED IN CONFIG FILE
#

# PROJECT_NAME           = $(DX_TITLE)
# PROJECT_BRIEF          = $(DX_BRIEF)
# PROJECT_LOGO           = $(DX_LOGO)
# OUTPUT_DIRECTORY       = $(DX_DESTDIR)
# LAYOUT_FILE            = $(DX_LAYOUT)
# INPUT                  = $(DX_INPUT)
# EXCLUDE                = $(DX_EXCLUDE_PAGES)
# IMAGE_PATH             = $(DX_IMAGE_PATH)
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
DX_BRIEF  ?= brief description

# directories
DX_DESTDIR     ?= ${builddir}/docs
DX_TAGDIR      ?= ${DX_DESTDIR}/dtags
DX_DESTTAG     ?= ${DX_TAGDIR}/${DX_PACKAGE_NAME}.tag
DX_SEARCHFILE  ?= ${DX_TAGDIR}/${DX_PACKAGE_NAME}.xml
DX_CHMFILE     ?= ${DX_TAGDIR}/${DX_PACKAGE_NAME}.chm

# style
DX_LOGO        ?= ${top_srcdir}/docs/config/style/logo.jpg
DX_LAYOUT      ?= ${top_srcdir}/docs/config/general_layout.xml
DX_IMGDIR      ?= img

# input default
DX_INPUT         ?=
DX_EXCLUDE_PAGES ?=
