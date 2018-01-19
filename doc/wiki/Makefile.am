include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/nodejs.mk

wiki.js: ##@node wiki js app install
wiki.js: $(NODEJS_MODULES_PATH)
	@ $(NPM) install $@ --prefix .


wiki-start: ##@wiki start
wiki-configure: ##@wiki configure
wiki-%:
	@ $(NODE) wiki $(subst wiki-,,$@)


