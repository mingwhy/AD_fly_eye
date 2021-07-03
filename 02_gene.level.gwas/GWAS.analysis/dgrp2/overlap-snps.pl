while(<>){
    s/\s+$//;
    $h{$_}++;
}
@k=keys %h;
for(@k){
    if($h{$_}>1){print "$_\n"}
}

