while(<>){
    s/\s+$//;
    ($snp,$type,$a)=(split/\s+/);
    ($siteclass,$transcript)=(split/\,/,$a);
#   print "$snp\t$type\t$siteclass\t$transcript\n";
    $siteclass=~s/SiteClass\[//g;
    $siteclass=~s/\]//g;
    #print "$snp\t$type\t$siteclass\n";
    @genes=(split/\;/,$siteclass);
    for(@genes){
        $gene=$_;
        @a=(split/\|/,$gene);
        print "$snp\t$type\t@a\n";
    }
}

