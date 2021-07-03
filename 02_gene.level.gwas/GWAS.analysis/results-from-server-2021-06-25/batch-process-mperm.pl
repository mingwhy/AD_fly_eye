#awk '{m=$2;for(i=2;i<=NF;i++)if($i>m)m=$i;print m}' FBgn0034530.mperm.dump.all | awk 'BEGIN{c=0;n=0}{if(NR==1)a=$1;else if(NR>1 && $1>a) c=c+1;n=n+1 } END{print a,c,n-1}' - 

$f=shift;
open F,"<$f";
while(<F>){
	s/\s+$//;
	push @file,$_
}
close F;
	
for(@file){
	$file=$_;
	$file=~/(FBgn[0-9]+)/;
	#print $1,"\n";
	$gene=$1;
	$cmd= 'awk \'{m=$2;for(i=2;i<=NF;i++)if($i>m)m=$i;print m}\' '.$file.' | awk \'BEGIN{c=0;n=0}{if(NR==1)a=$1;else if(NR>1 && $1>a) c=c+1;n=n+1 } END{print a,c,n-1}\' - ';
	#print "$cmd\n";
	$out=`$cmd`;
	print "$gene $out";	
}
