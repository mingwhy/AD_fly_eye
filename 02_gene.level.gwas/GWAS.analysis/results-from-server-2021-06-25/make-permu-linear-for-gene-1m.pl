
#$seed='123456';
#$seed='987654';
$seed='246810';
$dir=shift;
@files=glob("$dir/FBgn*");

for(@files){
	$gene=$_;
	#print "check $gene\n";	
	print 'plink --bfile ../../dgrp2-162lines/dgrp2-162lines.maf0.05 --allow-no-sex --pheno ../../input-files/eye-pheno.txt --covar ../../input-files/eye-assoc.txt keep-pheno-on-missing-cov --linear hide-covar mperm=1000000 --mperm-save-all --extract ',$gene; 
        print ' --threads 6 '; #use all threads on hyak actually slow things down
	$out=(split/\//,$gene)[-1];
	print " --out $out --seed $seed \n";
#	print " --out $out &\n";
}
#print "wait";

