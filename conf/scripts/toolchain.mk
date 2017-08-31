
################################################################################
# TOOLCHAIN
################################################################################

TOOLCHAIN_DIR ?= $(top_builddir)/toolchain

# TODO: remove this and put it to configure
# TODO: identify file type
if TOOLCHAIN_RETRIEVE_TAR
$(top_builddir)/toolchain:
	@ \
	  mkdir -p ${DL} $@; \
	  echo "getting toolchain from tar: ${TOOLCHAIN_TAR}"; \
	  _tar=${DL}/$$(echo $(TOOLCHAIN_TAR) | sed -e 's|.*/||'); \
	  test -f $$_tar || curl -SL $(TOOLCHAIN_TAR) > $$_tar; \
	  _wcl=$$(tar -tJf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
	  if test $$_wcl = 1; then \
	  tar -xJf $$_tar -C $@ --strip 1; \
	  else \
	  tar -xJf $$_tar -C $@; \
	  fi
else
$(top_builddir)/toolchain:
endif
