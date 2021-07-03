mkdir('snp200');
mkdir('snp201');
# perl *.pl ../naive-gwas/gene-snp-id.out 
while(<>){
    s/\s+$//;
    ($gene,@snp)=(split/\s+/);
    if(@snp>200){
        $out="./snp201/$gene";
    }else{
        $out="./snp200/$gene";
    }
    open F,">$out";
    for(@snp){
        print F "$_\n"
    }
    close F
}

