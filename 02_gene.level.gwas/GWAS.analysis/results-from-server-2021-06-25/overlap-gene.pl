$f=shift;
open F,"<$f";
while(<F>){
	$name=(split/\s+/)[0];
	$h{$name}=1;
}
close F;
while(<>){
	s/\s+$//;
	($snp,$p,@a)=(split/\s+/);
	for(@a){
		$name=$_;
		if(exists $h{$name}){
			print "$snp\n";
			last;
		}
	}
}

