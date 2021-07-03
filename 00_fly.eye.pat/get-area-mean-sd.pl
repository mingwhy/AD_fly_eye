$dir=shift;
@files=glob "$dir/*/*area.txt";
$title=0;
for(@files){
	$name=$_;
#$name=~m/(\d+)\.jpg/;
#$line=$1;
	$line=(split/\//,$name)[-1];

	open F,"<$name";
	$title++;
	$_=<F>;
	if($title==1){
		print "imageID\tnpoint";
		s/\s+$//;
		@a=(split/\s+/);
		$name=0;
		for(@a){
			$x='mean.'.$_;
			print "\t$x";
			$x='sd.'.$_;
			print "\t$x";
			$name++;
		}
		print "\n";
	}
	$h='';
	while(<F>){
		s/\s+$//;
		@a=(split/\s+/);
		for(0..$#a){
		   push @{$h->{$_}},$a[$_];	
		}
	}
	close F;

	$n=scalar(@{$h->{'0'}});
	print "$line\t$n";
	if($n<=2){
		for(1..$name){
			print "\tNA\tNA"
		}
		next
	}

	for(0..$#a){
		@a=@{$h->{$_}};		
		($mean,$sd) = &get_mean_sd(@a);
		print "\t$mean\t$sd";
		@{$h->{$_}}=();
	}
	print "\n";
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
