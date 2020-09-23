# Minimal makefile for Sphinx documentation
# 

ak__PYTHON_PACKAGES +=  sphinx \
						sphinx-rtd-theme \
					    git+https://github.com/rtfd/recommonmark.git
						


# ak__post_pip_install += recommonmark_template_install
# recommonmark_template_install:
# if ENABLE_JUPYTER_NOTEBOOK
# 	cp -a $(PYTHON_USERBASE)/share/jupyter
# endif



# You can set these variables from the command line, and also
# from the environment for the first two.
SPHINXOPTS    ?= 
SPHINXBUILD   ?= sphinx-build

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
sphinx-: ##@@docs commands
sphinx-%: conf.py # pip-install 
	@$(SPHINXBUILD) -b $* -c $(dir $<) "$(abs_srcdir)" "$(abs_builddir)/$*"  $(SPHINXOPTS) $(O)

# Put it first so that "make" without argument is like "make help".
.PHONY: sphinx-help
sphinx-help: ##@@docs het all possible commands
sphinx-help: # pip-install
	@$(SPHINXBUILD) -M help "$(abs_srcdir)" "$(abs_builddir)" $(SPHINXOPTS) $(O)

# GENERATE CONF .py
sphinx-gen-conf: ##@@docs generate conf.py example
sphinx-gen-conf: $(srcdir)/conf.py

## PERL SUBST ##
$(srcdir)/conf.py: __ax_pl_envsubst = $(PERL) -pe 's/([^\\]|^)\$$\(([a-zA-Z_][a-zA-Z_0-9]*)\)/$$1.$$ENV{$$2}/eg' < $1 > $2
$(srcdir)/conf.py: $(abs_top_srcdir)/conf/autoconf-sphinx/config/conf.py.in
	@ $(call __ax_pl_envsubst,$<,$@); 




# SPHINX VARIABLES

export DX_TITLE     ?= $(PACKAGE)
export DX_COPYRIGHT ?= Andrea Rigoni
export DX_AUTHOR    ?= $(PACKAGE_BUGREPORT)
export PACKAGE_VERSION

export DX_EXTENSIONS ?= recommonmark

export DX_templates = $(abs_top_srcdir)/conf/autoconf-sphinx/config/_templates
export DX_static    = $(abs_top_srcdir)/conf/autoconf-sphinx/config/_static






