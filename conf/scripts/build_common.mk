
MAKE_PROCESS  ?= $(shell grep -c ^processor /proc/cpuinfo)
DOWNLOAD_DIR  ?= $(top_builddir)/download

## ////////////////////////////////////////////////////////////////////////// ##
## ///  DOWNLOAD  /////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

define dl__download_tar =
 $(info "Downloading tar file: $(value $@_URL)")
 mkdir -p ${DOWNLOAD_DIR} $2; \
 _tar=${DOWNLOAD_DIR}/$$(echo $1 | sed -e 's|.*/||'); \
 test -f $$_tar || curl -SL $1 > $$_tar; \
 _wcl=$$(tar -tf $$_tar | sed -e 's|/.*||' | uniq | wc -l); \
 if test $$_wcl = 1; then \
  tar -xf $$_tar -C $2 --strip 1; \
 else \
  tar -xf $$_tar -C $2; \
 fi
endef

define dl__download_git =
 $(info "Downloading git repo: $(value $@_URL)")
 git clone $1 $2 $(if $($2_BRANCH),-b $($2_BRANCH))
endef

dl__tar_ext = %.tar %.tar.gz %.tar.xz %.tar.bz %.tar.bz2
dl__git_ext = %.git

$(DOWNLOADS):
	@ $(foreach x,$(value $@_URL),\
		$(info Download: $x) \
		$(if $(filter $(dl__tar_ext),$x),$(call dl__download_tar,$x,$@)) \
		$(if $(filter $(dl__git_ext),$x),$(call dl__download_git,$x,$@)) \
	   )
