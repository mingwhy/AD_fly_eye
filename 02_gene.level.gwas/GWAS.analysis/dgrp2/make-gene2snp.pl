while(<>){
    ($snp,$gene)=(split/\s+/)[0,2];
    $h->{$gene}->{$snp}=1;
}
@genes=keys %{$h};
for(@genes){
    $gene=$_;
    @a=keys %{$h->{$gene}};
    print "$gene\t@a\n";
}


