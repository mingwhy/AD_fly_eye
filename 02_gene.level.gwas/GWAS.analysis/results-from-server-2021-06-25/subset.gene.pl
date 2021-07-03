$f=shift;
open F,"<$f";
while(<F>){
	$name=(split/\s+/)[0];
	$h{$name}=1;
}
close F;
while(<>){
	 $name=(split/\s+/)[0];
	if(exists $h{$name}){print}
}
