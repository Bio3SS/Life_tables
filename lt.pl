
$R = 0;
@p = split(/\s+/, <>);
@f = split(/\s+/, <>);

@l = (1);

for ($i=0;$i<=$#p;$i++){
	$j = $i+1;
	$l[$i] = $l[$i-1]*$p[$i-1] if $i;
	$lf[$i] = $l[$i]*$f[$i];
	print "$j\t$f[$i]\t$p[$i]\t";
	printf "%5.3f\t%5.3f\n", $l[$i], $lf[$i];
	$R += $lf[$i];
}
printf "\\hline R\t\t\t\t%5.3f\n", $R;
