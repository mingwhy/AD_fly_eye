$dir=shift;
@files=glob "$dir/*/*coord.txt";
print "imageID\tnpoint\tnn.mean\tnn.sd\tcc.mean\tcc.sd\n";
for(@files){
	$name=$_;
#$name=~m/(\d+)\.jpg/;
#$line=$1;
	$line=(split/\//,$name)[-1];

	open F,"<$name";
	<F>;
	@x=();@y=(); @ecce=();
	while(<F>){
		($a,$b,$c)=(split/\s+/)[0,1,3];
		push @x,$a;
		push @y,$b;
		push @ecce,$c;
	}
	close F;

	$n=scalar(@x);
	if($n<=2){ print "$line\t$n\tNA\tNA\tNA\tNA\n";next}
	($ccmean,$ccsd) = &get_mean_sd(@ecce);
	@d=();
	for(1..$n){
		$i=$_;
		$xp=$x[$_-1];
		$yp=$y[$_-1];
		$dmin=-1;
		for(1..$n){
			$j=$_;
			next if($i==$j);
			$xc=$x[$j-1]; $yc=$y[$j-1];
			$d=(($xp-$xc)**2+($yp-$yc)**2)**0.5;
			if($dmin==-1){$dmin=$d}
			elsif($d<$dmin){$dmin=$d}
		}
		push @d,$dmin;
	}
	($mean,$sd) = &get_mean_sd(@d);
	print "$line\t$n\t$mean\t$sd\t$ccmean\t$ccsd\n";
}
sub get_mean_sd{
	my @d=@_;
	@d = sort(@d);
	if(@d<6){ return('NA','NA') }
	else{
		for(1..3){shift @d;pop @d}
		if(@d<=6){  return('NA','NA') }
	}
	my $sum=0; my $n=scalar(@d);
	my $mean=0; my $sd=0;
	for(@d){$sum+=$_}
	$mean=$sum/$n;
	for(@d){ $sd+= ($_-$mean)**2 }
	$sd=($sd/($n-1))**0.5;
	return($mean,$sd);
}
