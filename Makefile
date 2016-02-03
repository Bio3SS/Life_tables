# Life_tables
### Hooks for the editor to set the default target
current: target

target pngtarget pdftarget vtarget acrtarget: dandy.skeleton.tab.tex

##################################################################


# make files

Sources = Makefile .gitignore README.md stuff.mk LICENSE.md
include stuff.mk
-include $(ms)/os.mk
-include $(ms)/perl.def

newdir:

##################################################################

## Content

Sources += $(wildcard *.pl *.ssv *.h *.R *.t *.fmt)

# Life table calculations
%.tsv: %.ssv lt.pl
	$(PUSH)

# the tsv is made into a table using automatic rules from site-default

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

### Makestuff

## Change this name to download a new version of the makestuff directory
# Makefile: start.makestuff

-include $(ms)/git.mk
-include $(ms)/visual.mk

# -include $(ms)/wrapR.mk
# -include $(ms)/oldlatex.mk
