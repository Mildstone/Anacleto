include $(top_srcdir)/Common.mk
include $(top_srcdir)/conf/kscripts/python.mk


pythondir = $(PYTHON_USERBASE)
hello_PYTHON = hello.py
hellodir = /tmp/$(PACKAGE)



# /////////////////////////////////////////////////
# //  CONDA  //////////////////////////////////////
# /////////////////////////////////////////////////

if PYTHON_ENV_SYSTEM_CONDA

CONDA_ENV = myenv
CONDA_DIR = /home/andrea/miniconda3

__conda_init = eval "$$($(CONDA_DIR)/bin/conda shell.$(notdir $(SHELL)) hook)"

conda-envs: SHELL = bash # sh is not supported by conda
conda-envs:
	$(__conda_init); conda env list

endif


