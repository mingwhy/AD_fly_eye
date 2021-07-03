while(<>){
	s/\s+$//;
	($snp,$p,@gene)=(split/\s+/);
	for(@gene){
		push @{$h1->{$_}},$snp;
		push @{$h2->{$_}},$p;
	}
}
open F1,">gene-snp-id.out";
open F2,">gene-snp-pvalue.out";
@k=keys %{$h1};
for(@k){
	$gene=$_;
	print F1 "$gene\t@{$h1->{$gene}}\n";
	print F2 "$gene\t@{$h2->{$gene}}\n";
}


