$dir=shift;
@f=glob "$dir/*dump*";
$all=scalar(@f);
$n=$all/20;
$t=$n % 20;
print "$n\t$t\t$all\n";
$i=0;
while(@f){
	$i++;
	$name='name.list.'.$i;	
	open F,">$name";
	for(1..400){
		if(@f==0){last}
		$name=shift @f;
		print F $name,"\n";
	}
	close F;
} 

