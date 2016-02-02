use strict;
 
my %files;
 
# Slurp!  Yo.
undef $/;
 
# Treat first argument as input file
my $infile_name = shift(@ARGV);
open F, $infile_name;
my $infile = <F>;
 
# Read remaining files into file hash:
foreach my $fn (@ARGV){
	open F, $fn;
	$fn =~ /[^.]*$/;
	$files{$&} .= <F>;
}
 
# Process format file
$files{fmt} =~ s/^\s+//;
my (%spec, %com);
foreach (split /\n+/, $files{fmt}){
	next if /^#/;
 
 	# Special commands begin with !, regular have no !
	if (s/^!//){
		die ("Unrecognized format line $_") unless s/^\s*(\S+)\s+//;
		my $tag = $1;
		$spec{$tag}=$_;
		$spec{$tag} =~ s/\\n\b/\n/g;
		$spec{$tag} =~ s/\\t\b/\t/g;
	} else {
		die ("Unrecognized format line $_") unless s/^\s*(\S+)\s*//;
		$com{$1}=$_;
	}
}

# Default specials
$spec{tempSep} = '--------------------------------------+\s+'
	unless defined $spec{tempSep};
$spec{parSep} = '\n{2,}'
	unless defined $spec{parSep};
$spec{parJoin} = "\n\n"
	unless defined $spec{parJoin};
 
# Print top of template file
my @tmp = split(/$spec{tempSep}/, $files{tmp});
print $tmp[0];
 
# Split input file
$infile =~ s/.*$spec{START}//s if defined $spec{START};
$infile =~ s/$spec{END}.*//s if defined $spec{END};

my @pages;
if (defined $spec{pageSep}){
	@pages = split (/$spec{pageSep}/,$infile);
} else {
	@pages = ($infile);
}
 
## Process pages
foreach(@pages){
	my @page;
	my $currlevel=0;
 
	# Don't choke on non-blank blank lines
	s/\n[\s]+\n/\n\n/g;
 
	# Comments start with # (modularize this eventually)
	s/^#+[ #][^\n]*\n//;
	s/\n#+[ #][^\n]*//g;
 
	my $first=1;
 
	# Split into paragraphs
	foreach (split(/$spec{parSep}/, $_)){
 
		# Leading newlines bad
		s/\n*//;
 
		# Count $linelevel of this line, compare to global $currlevel
		my $linelevel=0;
 
		# Hot changes (underscores, square brackets, etc.)
 
		# Underscores
		# Latex math Trick: EM does not span tab.
		if (defined $spec{EM}){
			my @em = split /%/, $spec{EM};
			s/_([A-Za-z0-9 .,;-]*)_/$em[0]$1$em[1]/g;
		}
 
		# Square brackets
		if (defined $spec{SQUARE}){
			my @em = split /%/, $spec{SQUARE};
			s/\[([^\]]*)]/$em[0]$1$em[1]/g;
		}
 
		# Double quotes
		if (defined $spec{QUOTE}){
			my @em = split /%/, $spec{QUOTE};
			s/"([^"]*)"/$em[0]$1$em[1]/g;
		}

		# Internal tab replacement (temporary!)
		if (defined $spec{intTab}){
			s/\t/$spec{intTab}/g;
		}
 
		# Find "command" word
		my ($lead, $head) = /(\s*)([\w*]*)/;
 
		# Look up commands
		my $pat = "";
		if (defined $com{$head}){
			$pat = $com{$head};
			s/\s*[\w*]+[ 	]*//;
		} elsif ($first and $head and defined $com{DEFHEAD}){
			$pat = $com{DEFHEAD};
		} elsif (defined $com{DEFCOMM}){
			$pat = $com{DEFCOMM};
		}
		$first=0 if $head;
 
		# Replace % with an illegal string
		s/%/@#/gs;
 
		# Replace lines by appropriate patterns
		if ($pat){
			s/^\s*//; # Lead stays with pattern, strip from string
			my $str = $_;
			$_ = $lead.$pat;
 
			#Expand escapes before pattern expansion
			s/\\n /\n/gs;
			s/\\n\b/\n/gs;
			s/\\t /\t/gs;
			s/\\t\b/\t/gs;
 
			while (/%/){
				# Replace %% with whole remaining string
				if (/^[^%]*%%/){
					s/%%/$str/g;
					$str = "";
				}
 
				# %+ uses, keeps whole remaining string
				elsif (/^[^%]*%[+]/){
					s/%[+]/$str/gs;
				}
 
				# %! eats whole remaining string
				elsif (/^[^%]*%!/){
					s/%!//gs;
					$str = "";
				}
 
				# %| gets next sentence (use | to avoid period)
				elsif (/^[^%]*%[|]/){
					$str =~ s/^([^|.!?]*[|.!?])\s*// or 
						die "%| doesn't match $str";
					my $p = $1;
					$p =~ s/[|]$//;
					s/%[|]/$p/;
				}
 
				# %_ gets current line (not required to exist)
				elsif (/^[^%]*%_/){
					$str =~ s/^([^\n]*)\n//;
					my $p = $1;
					s/%_/$p/;
				}
 
				# %^ optionally takes next word
				elsif (/^[^%]*%\^/){
					$str =~ s/\s*(\S*)\s*//;
					my $p = $1;
					s/%\^/$p/;
				}
 
				# Otherwise, % requires next word
				else{
					$str =~ s/\s*([^\s|]+)\s*//
						or die "% doesn't match $str in $_\n";
					my $p = $1;
					s/%/$p/;
				}
			}
			print STDERR "WARNING: orphan text $str\n"
				unless ($str =~ /^\s*$/) or (/NULLPAGE/);
		}
 
		redo if  s/^(\s*)\^/$1/;
 
		# Hack (tex only, for now)
		s/@#/\\%/gs;
 
		# Leading tabs
		s/\s+$//;
		next if /^$/;
		if (defined $spec{TAB}){
			$linelevel++ while s/^$spec{TAB}//;
			while ($currlevel<$linelevel){
				push @page, $spec{BIZ} if defined $spec{BIZ};
				$currlevel++;
				die ("Too many tabs ($linelevel > $currlevel) on line $_") 
					if $currlevel<$linelevel;
			}
		}
 
		while ($currlevel>$linelevel){
			push @page, $spec{EIZ} if defined $spec{EIZ};
			$currlevel--;
		}
		s/^/$spec{ITEM} / unless $currlevel==0;
 
 
		push @page, "$_" unless /^$/;
	}
	# End of paragraph loop
 
	while ($currlevel>0){
		push @page, $spec{EIZ} if defined $spec{EIZ};
		$currlevel--;
	}
 
	next if (@page==0); # Don't print blank page (if you can help it)
	my $page = join ($spec{parJoin}, @page);
 
	next if $page =~ /^\s*NULLPAGE\b/;
	$page =~ s/\bENDOFPAGE\b.*//s;
 
	unless ($page =~ s/\bNOFRAME\b//g){
		if (defined $spec{BSL}){
			$page =~ s/^/\n$spec{BSL}\n/ unless $page =~ s/PAGESTART/\n$spec{BSL}\n/;
		}
		$page .=  "\n$spec{ESL}\n" if defined $spec{ESL};
	}
 
	print "$page";
 
}
 
# Bottom of template file
print "\n$tmp[1]";
