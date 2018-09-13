include $(top_srcdir)/Common.mk

## AWK ##
# I was not able to compile regex for escaped $
__ax_awk_envsubst = $(AWK) '{while(match($$0,"[^\\$$]{[^}]*}")) {var=substr($$0,RSTART+2,RLENGTH-3);gsub("[$$]{"var"}",ENVIRON[var])}}1' < $1 > $2

## PERL ##
__ax_pl_envsubst = $(PERL) -pe 's/([^\\]|^)\$$\{([a-zA-Z_][a-zA-Z_0-9]*)\}/$$1.$$ENV{$$2}/eg' < $1 > $2

SUFFIXES = .sh .sh.template
.sh.template.sh:
	@ $(call __ax_pl_envsubst,$<,$@); \
	source ./$@




export VERSION
export top_srcdir
export top_builddir

SH_FILES = script.sh
CLEANFILES = $(SH_FILES)
all: $(SH_FILES)

