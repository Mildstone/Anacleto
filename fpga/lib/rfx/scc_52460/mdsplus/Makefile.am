include $(top_srcdir)/Common.am

AM_CFLAGS = -I$(srcdir)/../linux/src

noinst_LIBRARIES = librfx_scc52460_2_0.a
librfx_scc52460_2_0_a_SOURCES = rfx_scc52460_2_0.c


mdsplus_FILES = __init__.py \
				rfx_scc53460_2_0.py


## ////////////////////////////////////////////////////////////////////////// ##
## //  DEPLOY  ////////////////////////////////////////////////////////////// ##
## ////////////////////////////////////////////////////////////////////////// ##

.PHONY: deploy
deploy: librfx_scc52460_2_0.a $(mdsplus_FILES)
if WITH_DEVICE_SSHKEY
	@ echo " --- deploying mdsplus to target device: ${DEVICE_NAME} using key ---";
	scp -i $(DEVICE_SSHKEY) $^ $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);
else
if WITH_DEVICE_SSHPASSWD
	@ echo " --- deploying mdsplus to target device: ${DEVICE_NAME} using passwd ---";
	sshpass -p ${DEVICE_PASSWD} scp $^ $(DEVICE_USER)@$(DEVICE_IP):$(DEVICE_MODULES_DIR);
endif
endif
