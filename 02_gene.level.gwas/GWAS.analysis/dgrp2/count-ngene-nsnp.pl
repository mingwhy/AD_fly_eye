$sig=shift;

while(<>){
    s/\s+$//;
    ($snp,$gene)=(split/\s+/)[0,2];
    if($sig eq 'snp'){
        $h{$snp}++;
    }else{ $h{$gene}++ }
}
@a=keys %h;
for(@a){
    print "$h{$_}\n";
}

