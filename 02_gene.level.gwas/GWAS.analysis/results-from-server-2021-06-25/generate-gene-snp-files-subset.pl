# perl *.pl ../naive-gwas/gene-snp-id.out 
while(<>){
    s/\s+$//;
    ($gene,@snp)=(split/\s+/);
    $out="./$gene";
    open F,">$out";
    for(@snp){
        print F "$_\n"
    }
    close F
}

