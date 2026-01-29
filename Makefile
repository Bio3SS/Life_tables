# Life_tables

current: target
-include target.mk

-include makestuff/perl.def

######################################################################

# Content

vim_session:
	bash -cl "vmt"

##################################################################

## Aim to get rid of the weird pl / ssv stuff upstream and start with 
## dataframe-like input files (a column for f and p, or else m and two ps
## merge some other stream (with the m ⇒ f) that is SOMEWHERE (maybe here)

## Content

Sources += $(wildcard *.pl *.ssv *.h *.R *.t *.fmt *.pars)

sourcelist: .
	ls -t *.ssv > $@

# Life table calculations
## User provides an .ssv file, which is made into a .tsv life table
## To finish the pipeline, we later need a .h file which makes the header.
Ignore += *.tsv
%.tsv: %.ssv lt.pl
	$(PUSH)

# Make un-filled version
Ignore += *.empty.tsv
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

## Why did I have to make pre.tsv manually? It should chain 2026 Jan 29 (Thu)
## pre.tab.tex: pre.tsv
Ignore += *.tab.tex
%.tab.tex: %.tsv %.tmp tab.fmt dmu.pl
	$(PUSH)

params.tex standalone.tex: %.tex: params.tsv %.tmp tab.fmt dmu.pl
	perl -f dmu.pl $^ > $@

######################################################################

### Makestuff

Sources += Makefile

## Sources += content.mk
## include content.mk

Ignore += makestuff
msrepo = https://github.com/dushoff
Makefile: makestuff/Makefile
makestuff/Makefile:
	git clone $(msrepo)/makestuff
	ls $@

-include makestuff/os.mk

## -include makestuff/wrapR.mk
-include makestuff/texj.mk

-include makestuff/git.mk
-include makestuff/visual.mk
-include makestuff/projdir.mk
