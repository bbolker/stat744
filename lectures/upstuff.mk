## Utility .mk file for directories that want to link _up_ to makestuff
## For now, we're using chains of symbolic links
## Might be better to copy to a fake name (util.mk), so that the initial Makefile can be the same for hybrid and sub directories

ms = makestuff
-include local.mk
-include $(ms)/os.mk

Sources += $(ms)

Makefile: $(ms)
$(ms): 
	ls -d ../makestuff && /bin/ln -fs ../makestuff .

Ignore += $(ms)

