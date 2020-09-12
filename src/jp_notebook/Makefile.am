include $(top_srcdir)/Common.mk



ipython: SHELL=$(PYTHON)
ipython: ##@python ipython shell
	from IPython import start_ipython; \
	start_ipython()


runpy: ##@python run script in $NAME
runpy: $(if $(NAME),$(srcdir)/$(NAME))
	$(PYTHON_SHELL) $<


pythondir = $(PYTHON_USERBASE)


hello_PYTHON = hello.py
hellodir = /tmp/$(PACKAGE)



if PYTHON_ENV_SYSTEM_CONDA


CONDA_ENV = myenv
CONDA_DIR = /home/andrea/miniconda3


__conda_init = eval "$$($(CONDA_DIR)/bin/conda shell.$(notdir $(SHELL)) hook)"

conda-envs: SHELL = bash
conda-envs:
	$(__conda_init); conda env list

endif






## /////////////////////////////////////////////////
## ///  JUPYTER   //////////////////////////////////
## /////////////////////////////////////////////////

if ENABLE_JUPYTER_NOTEBOOK

jpnb-start:  ##@jupyter start notebook server
jpnb-stop:   ##@jupyter stop notebook server
jpnb-passwd: ##@jupyter set new custom passwd

endif
