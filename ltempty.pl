 
while(<>){
	chomp;
	s/[^	]*	[^	]*$/	/;
	print "$_\n";
}
