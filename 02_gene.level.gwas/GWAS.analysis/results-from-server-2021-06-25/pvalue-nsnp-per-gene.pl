$f=shift;
open F,"<$f";
while(<F>){
	s/\s+$//;
	@a=(split/\s+/);
	$gene=shift @a;
	$h{$gene}=scalar(@a);
}
close F;
#$a=<>;
#genename	obs	nperm	ngreater	prop
#$a=~s/\s+$//;
#@a=(split/\s+/,$a);
#$gene=shift @a;
print "genename nsnp obs ngreater nperm prop\n";
while(<>){
	s/\s+$//;
	@a=(split/\s+/);
	$gene=shift @a;
	$nperm=pop @a; $ngreater=pop @a;
	$prop=($ngreater+1)/($nperm+1); # (R+1)/(N+1)
	print "$gene $h{$gene} @a $ngreater $nperm $prop\n";
}
