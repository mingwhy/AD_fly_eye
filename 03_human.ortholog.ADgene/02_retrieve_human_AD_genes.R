library(biomaRt)
library(AnnotationDbi)
library(org.Dm.eg.db,verbose=F,quietly=T)
library(readxl)
library(rvest)
library(XML)
options(stringsAsFactors = F)

# data download from: https://www.ebi.ac.uk/gwas/downloads
# https://www.ebi.ac.uk/gwas/docs/file-downloads
# All associations v1.0 (https://www.ebi.ac.uk/gwas/api/search/downloads/full)
# $  head -1 gwas_catalog_v1.0-associations_e100_r2021-06-08.tsv | cat - <(grep 'Alzheimer' gwas_catalog_v1.0-associations_e100_r2021-06-08.tsv) >Alzheimer.gwas.txt 
# $ awk -F'\t' '{print NF}' Alzheimer.gwas.txt | head # 34 columns in the file
df=read.csv('Alzheimer.gwas.txt',sep='\t',fill=T,header=T)
dim(df)
colnames(df)
summary(df$P.VALUE)
unique(df$DISEASE.TRAIT)

# do you wnat to further filter using 'DISEASE.TRAIT' column
df1=df[grep('Alzheimer', df$DISEASE.TRAIT,ignore.case=T),]
dim(df1)

# extract human genes
#AD.genes=df1$MAPPED_GENE
AD.genes=df$MAPPED_GENE
AD.genes=sapply(AD.genes,function(x){
  tmp=unlist(strsplit(x,'\\-|x| '))
  tmp[tmp!='']
})
head(AD.genes)
AD.genes=unique(unlist(AD.genes))
names(AD.genes)=NULL
length(unique(AD.genes)) # 6817 human AD genes for df; 1445 genes for df1, 

# use DIOPT to retrieve fly orthologs
# if 'humanADgenes_flyorthologs.DIOPT.rds' file doesn't exit, run below
if(!file.exists('humanADgenes_flyorthologs.DIOPT.rds')){
  # web scraping: DIOPT (https://www.flyrnai.org/diopt) online tool 
  url<-"https://www.flyrnai.org/diopt"; #the url we'd like to 'talk' to
  x=read_html(url)
  session<-html_session(url) #set up a "channel" to talk
  html_form(session) #have a look at the configuration of this 'channel'
  
  form<-html_form(session)[[1]]
  form=set_values(form,input_species='9606')
  form=set_values(form,output_species='7227')
  #form$fields$input_species
  #form$fields$output_species
  
  #<field> (textarea) gene_list: 
  genes.DIOPT=list();
  igene=0;
  
  for(gene in AD.genes){
    form<-set_values(form, gene_list =gene)
    #<field> (textarea) gene_list: FBgn0029663
    
    # check ALL for 'Search Field' and uncheck others
    # locate Search Field in the form object list
    #form$fields[[5]];form$fields[[6]];form$fields[[24]];form$fields[[25]]
    for(i in 6:24){
      form$fields[[i]]$value<-'***'
    }
    #form$fields[[25]];form$fields[[43]]
    for(i in 26:43){
      form$fields[[i]]$value<-'***'
    }
    
    result <- submit_form(session,form,submit='submit')
    #<field> (submit) submit: Submit Search
    
    ## process output
    x<-read_html(result)
    x.out=html_table(x,fill = T)
    if(length(x.out)==0){
      #Your 1 query symbols mapped to 0 genes.
      genes.DIOPT[[gene]]<-NULL
    }  
    else if(length(x.out)>1){
      # Your 1 query symbols mapped to 1 genes. 1 of them had no orthologs. 
      genes.DIOPT[[gene]]<-x.out[[2]]
    }else{
      ## output this xml object to local 'test.html' file
      if(F){
        sink("test.html");
        xmlNode(x)
        sink()
        browseURL('test.html')
      }
      #length(x.out)
      #colnames(x.out[[1]])
      genes.DIOPT[[gene]]<-x.out[[1]]
    }
    igene=igene+1;
    cat('#gene ',igene,'is done\n')
  }
  #sapply(flygenes.DIOPT,nrow)
  saveRDS(genes.DIOPT,'humanADgenes_flyorthologs.DIOPT.rds')
}  

genes.DIOPT=readRDS('humanADgenes_flyorthologs.DIOPT.rds')
#genes.DIOPT.df=Reduce(`rbind`,genes.DIOPT) #slow
#saveRDS(genes.DIOPT.df,'humanADgenes_flyorthologs.DIOPT.df.rds')
genes.DIOPT.df=readRDS('humanADgenes_flyorthologs.DIOPT.df.rds')
dim(genes.DIOPT.df); #16751    18

# use Weighted Score >=3 to filter returned hits
hit.genes=genes.DIOPT.df[genes.DIOPT.df$`Weighted Score`>=3 & !is.na(genes.DIOPT.df$`Weighted Score`),]
summary(hit.genes$`Weighted Score`)
length(unique(hit.genes$`Search Term`)) #1842 human genes, out of 6817 human AD genes have fly orthologs

hit.genes.best=hit.genes[hit.genes$`Best Score`=='Yes',] #only keep the best match
length(unique(hit.genes.best$`Search Term`))#1842 human AD gene have >=1 fly orthologs
nrow(hit.genes);nrow(hit.genes.best)
length(unique(hit.genes.best$`Fly Species Gene ID`)) #1626 unique fly genes, but they may not all show up in the 16631 gwas gene list.

  
# read into 16631 fly genes ranked by P value
df.gwas<-readxl::read_excel('gwas_on_162DGRPlines.xlsx')
df.gwas=df.gwas[order(df.gwas$ngreater,decreasing = F),] 
nrow(df.gwas) #16631 fly genes in total
sum(df.gwas$genename %in% hit.genes.best$`Fly Species Gene ID`) #1573 unique gene overlapped
# extract these 1573 fly genes with human AD ortholog
AD.pathway=df.gwas[df.gwas$genename %in% hit.genes.best$`Fly Species Gene ID`,]$genename

# use GSEA to test: do these 1573 gene randomly distributed in our ranked 16631 fly gene list
library(fgsea)
library(data.table)
library(ggplot2)
score=df.gwas$`pvalue=(1+ngreater)/(1+nperm)`
names(score)=df.gwas$genename

input.pathways=list('AD'=AD.pathway);
fgseaRes=fgsea(pathways=input.pathways,
               stats=score,minSize = 5,maxSize = 5000,nperm = 1000)
fgseaRes

plotEnrichment(input.pathways[["AD"]],
               score) + labs(title="7 RNAi genes")
plot.new()
plotGseaTable(input.pathways["AD"], score, fgseaRes, 
              gseaParam = 0.5)

######################################## 
# the 7 genes used in RNAi validation:
# 1nd RNAi: misfire (FBgn0266757), Sodh-1 (FBgn0024289), Eglp4 (FBgn0034885), GckIII (FBgn0266465). 
# 2nd RNAi: Eglp2 (FBgn0034883), CG6984 (FBgn0034191), Spel (FBgn0015546)
gene7=c('FBgn0266757','FBgn0024289','FBgn0034885','FBgn0266465','FBgn0034883','FBgn0034191','FBgn0015546');
sum(gene7 %in% genes.DIOPT.df$`Fly Species Gene ID`)
gene7[!gene7 %in% genes.DIOPT.df$`Fly Species Gene ID`]

score[gene7]
rank(score)[gene7]

score= -log(score,base=10)
score[gene7]

######################################## 
## some column description of the downloaded file: 
# (a full description can be seen here: https://www.ebi.ac.uk/gwas/docs/fileheaders)
# DISEASE/TRAIT*
# REPORTED GENE(S)*: Gene(s) reported by author
# MAPPED GENE(S)*: Gene(s) mapped to the strongest SNP. If the SNP is located within a gene, that gene is listed. If the SNP is located within multiple genes, these genes are listed separated by commas. If the SNP is intergenic, the upstream and downstream genes are listed, separated by a hyphen.
# UPSTREAM_GENE_ID*: Entrez Gene ID for nearest upstream gene to rs number, if not within gene
# DOWNSTREAM_GENE_ID*: Entrez Gene ID for nearest downstream gene to rs number, if not within gene
# SNP_GENE_IDS*: Entrez Gene ID, if rs number within gene; multiple genes denotes overlapping transcripts
## some FQA from GWAS Catalog website
#https://www.ebi.ac.uk/gwas/docs/faq
#2. How do I search by gene?
# You can search for a gene in the main search bar eg. STAT4. This will return any matching genes, as well as variants annotated with that gene by out mapping pipeline. The results may also include publications with the gene name in the title.
# The "Gene" page provides a list of all associations mapped to that gene as well as other gene-specific data. See Genomic mappings below for details of how we map variants to genes. Note that this may not always match the gene reported by authors for a given variant, as they may use different criteria.
# Author-reported genes can be found in the full data download. Opening the file in Excel and applying a filter for your gene of interest to the REPORTED GENE(S) column will enable you to extract all associations in that gene.
#E. Genomic mappings
#2. Which genome build is the Catalog on?
#  Data in the GWAS Catalog is currently mapped to genome assembly GRCh38.p13 and dbSNP Build 153.

