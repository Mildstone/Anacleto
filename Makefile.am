include Common.am
AM_MAKEFLAGS = -j$(MAKE_PROCESS)

all: ##@all download and build the selected toolchain and the linux image
all:

################################################################################
# TOOLCHAIN
################################################################################

# TODO: remove this and put it to configure
# TODO: identify file type
if TOOLCHAIN_LINARO_BIN
$(top_builddir)/toolchain:
	@ \
	  mkdir -p ${DL} $@; \
	  echo "getting toolhain from tar: ${LINARO_BIN_TAR}"; \
	  _tar=${DL}/$$(echo $(LINARO_BIN_TAR) | sed -e 's|.*/||'); \
	  test -f $$_tar || curl -SL $(LINARO_BIN_TAR) > $$_tar; \
	  _wcl=$$(tar -tJf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
	  if test $$_wcl = 1; then \
	  tar -xJf $$_tar -C $@ --strip 1; \
	  else \
	  tar -xJf $$_tar -C $@; \
	  fi
else
$(top_builddir)/toolchain:
endif


clean-local:

MOSTLYCLEANFILES =

