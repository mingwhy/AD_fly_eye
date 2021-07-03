# filtered gwas snp output and dgrp2-snp-gene overlap
$f=shift;
open F,"<$f";
<F>;
while(<F>){
	($snp,$p)=(split/\s+/)[2,-2];
	$h{$snp}=$p;
}
close F;

while(<>){
	unless(/FBgn/){next}
	s/\s+$//;
	@a=(split/\s+/);
	$snp=shift @a;
        if(exists $h{$snp}){
            print "$snp\t$h{$snp}\t@a\n";
        }
}
#print "snpID\tpvalue\trelated.genes\n";

