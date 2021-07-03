while(<>){
	s/\s+$//;
	($gene,@a)=(split/\s+/);
#	print "check $gene @a\n";
	$n=scalar(@a);
	for(@a){
		$_=sprintf("%.10f",$_);
	}
	@a=sort(@a);
	$m=shift @a;
	print "$gene\t$n\t$m\n";
}
