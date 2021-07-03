while(<>){
    ($snp,$gene)=(split/\s+/)[0,2];
    $h->{$snp}->{$gene}=1;
}
@snps=keys %{$h};
for(@snps){
    $snp=$_;
    @a=keys %{$h->{$snp}};
    print "$snp\t@a\n";
}


