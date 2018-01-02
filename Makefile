# Life_tables
### Hooks for the editor to set the default target
current: target
-include $(ms)/target.mk

##################################################################

# make files

Sources = Makefile .gitignore README.md sub.mk LICENSE.md
include sub.mk
-include $(ms)/perl.def

newdir:

##################################################################

## Content

Sources += $(wildcard *.pl *.ssv *.h *.R *.t *.fmt *.pars)

sourcelist: .
	ls -t *.ssv > $@

# Life table calculations
## User provides an .ssv file, which is made into a .tsv life table
## To finish the pipeline, we later need a .h file which makes the header.
%.tsv: %.ssv lt.pl
	$(PUSH)

# Make un-filled version
%.empty.tsv: %.tsv ltempty.pl
	$(PUSH)

%.skeleton.tsv: %.tsv ltskeleton.pl
	$(PUSH)

%.tmp: %.h lt.t
	cat $^ > $@

# This may not work if you try to make empty version first.
%.empty.tmp: %.tmp
	/bin/cp -f $< $@

%.skeleton.tmp: %.tmp
	/bin/cp -f $< $@

%.before.h: before.h
	/bin/ln -fs $< $@

%.before.Rout: table.Rout %.Rout before.R
	$(run-R)

%.after.h: after.h
	/bin/ln -fs $< $@

%.after.Rout: table.Rout %.Rout after.R
	$(run-R)

%.ssv: %.Rout ;

%.tab.tex: %.tsv %.tmp tab.fmt dmu.pl
	$(PUSH)

params.tex standalone.tex: %.tex: params.tsv %.tmp tab.fmt dmu.pl
	perl -f dmu.pl $^ > $@

######################################################################

## Version parsing for 3SS tests
%-1-version.R %-2-version.R %-3-version.R %-4-version.R %-5-version.R: %.pars versions.pl
	$(PUSHOUT)

### Makestuff

## Change this name to download a new version of the makestuff directory
# Makefile: start.makestuff

-include $(ms)/git.mk
-include $(ms)/visual.mk

-include $(ms)/wrapR.mk
# -include $(ms)/oldlatex.mk
