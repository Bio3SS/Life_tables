 
while(<>){
	chomp;
	s/\t.*/\t\t\t/;
	print "$_\n";
}
