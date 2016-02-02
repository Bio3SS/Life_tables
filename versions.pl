use strict;
use 5.10.0;

my $version = shift(@ARGV);
$version =~ s/-version.*//;
$version =~ s/.*-//;

$version--;

my $num = "[\\w\\\\]*[.]?[\\w\\\\]*";

while (<>){
	while (my($head, $choice, $tail)
		= ($_ =~ m|(.*?)($num/$num/$num/$num/$num)(.*)|s))
	{
		my @choice=(split m|[/]|, $choice);
		$choice="$choice[$version]";
		$_ = "$head$choice$tail";
	}
	print;
}
