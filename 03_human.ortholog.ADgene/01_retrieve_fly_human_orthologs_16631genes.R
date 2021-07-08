library(biomaRt)
library(AnnotationDbi)
library(org.Dm.eg.db,verbose=F,quietly=T)
library(readxl)
library(rvest)
library(XML)
library(RVenn)
options(stringsAsFactors = F)

# read in fly genes and use DIOPT to retrieve human orthologs
df<-readxl::read_excel('gwas_on_162DGRPlines.xlsx')
df=df[order(df$ngreater,decreasing = F),] 
nrow(df) #16631 fly genes in total
df.gwas=df

# if 'flygenes.DIOPT.rds' file doesn't exit, run below
if(!file.exists('flygenes.DIOPT.rds')){
  # web scraping: DIOPT (https://www.flyrnai.org/diopt) online tool 
  url<-"https://www.flyrnai.org/diopt"; #the url we'd like to 'talk' to
  x=read_html(url)
  session<-html_session(url) #set up a "channel" to talk
  html_form(session) #have a look at the configuration of this 'channel'
  
  form<-html_form(session)[[1]]
  #<field> (textarea) gene_list: 
  
  form=set_values(form,input_species='7227') #fly
  form=set_values(form,output_species='9606') #human
  #form$fields$input_species
  #form$fields$output_species
  
  flygenes.DIOPT=list();
  igene=0;
  
  for(gene in df$genename){
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
      flygenes.DIOPT[[gene]]<-NULL
    }  
    else if(length(x.out)>1){
      # Your 1 query symbols mapped to 1 genes. 1 of them had no orthologs. 
      flygenes.DIOPT[[gene]]<-x.out[[2]]
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
      flygenes.DIOPT[[gene]]<-x.out[[1]]
    }
    igene=igene+1;
    cat('#gene ',igene,'is done\n')
  }
  #sapply(flygenes.DIOPT,nrow)
  saveRDS(flygenes.DIOPT,'flygenes.DIOPT.rds')
}  

# process 
flygenes.DIOPT = readRDS('flygenes.DIOPT.rds')
colnames(flygenes.DIOPT[[1]])
sapply(flygenes.DIOPT,ncol) #all have the same number of columns

# transform list into data.frame
#flygenes.DIOPT.df=Reduce(`rbind`,flygenes.DIOPT) #this is slow
#dim(flygenes.DIOPT.df) #92851    18
#saveRDS(flygenes.DIOPT.df,'flygenes.DIOPT.df.rds')
flygenes.DIOPT.df=readRDS('flygenes.DIOPT.df.rds')
colnames(flygenes.DIOPT.df)
summary(flygenes.DIOPT.df$`Weighted Score`)

# use Weighted Score >=3 to filter returned hits
hit.genes=flygenes.DIOPT.df[flygenes.DIOPT.df$`Weighted Score`>=3 & !is.na(flygenes.DIOPT.df$`Weighted Score`),]
summary(hit.genes$`Weighted Score`)
length(unique(hit.genes$`Search Term`))#8430 genes

hit.genes.best=hit.genes[hit.genes$`Best Score`=='Yes',]
length(unique(hit.genes.best$`Search Term`))#8430 fly gene have >=1 human orthologs
nrow(hit.genes);nrow(hit.genes.best)

hit.genes.best[hit.genes.best$`Search Term`=='FBgn0013279',] #one-to-many relationship
fly.gene.with.human.orthologs.df=hit.genes.best;
fly.gene.with.human.orthologs=(unique(hit.genes.best$`Search Term`))#8430 fly gene have>=1 human orthologs

## read in human AD genes
genes.DIOPT.df=readRDS('humanADgenes_flyorthologs.DIOPT.df.rds')
# use Weighted Score >=3 to filter returned hits
hit.genes=genes.DIOPT.df[genes.DIOPT.df$`Weighted Score`>=3 & !is.na(genes.DIOPT.df$`Weighted Score`),]
summary(hit.genes$`Weighted Score`)
length(unique(hit.genes$`Search Term`)) #1842 human genes, out of 6817 human AD genes have fly orthologs
hit.genes.best=hit.genes[hit.genes$`Best Score`=='Yes',]
length(unique(hit.genes.best$`Search Term`))#1842 human AD gene have >=1 fly orthologs
nrow(hit.genes);nrow(hit.genes.best)

sum(fly.gene.with.human.orthologs %in% hit.genes.best$`Fly Species Gene ID`) #1573 fly genes which has human ortholog and related to AD

fly.human.AD=fly.gene.with.human.orthologs[fly.gene.with.human.orthologs %in% hit.genes.best$`Fly Species Gene ID`]
length(fly.human.AD) #1573 genes

##########################################################################################
## top 0.01 gene enrichment analysis
cutoff=0.002;
top.genes=df.gwas[df.gwas$`pvalue=(1+ngreater)/(1+nperm)`<cutoff,]
dim(top.genes)
obs=sum(top.genes$genename %in% hit.genes.best$`Fly Species Gene ID`) #23

name1=paste0('top_',cutoff);
out<-Venn(list('fly.GWAS.top.genes'=top.genes$genename,'Human.AD.genes'=fly.human.AD)) #173 overlap
ggvenn(out)

set.seed(123)
n.simu=10000;
simu.out=rep(0,n.simu)
for(i in 1:n.simu){
  pse=sample(1:nrow(df.gwas),nrow(top.genes),replace = F)
  test=df.gwas[pse,]$genename
  #simu.out[i]=sum(test %in% hit.genes.best$`Fly Species Gene ID`)
  simu.out[i]=sum(test %in% fly.human.AD)
}

(p.value= (sum(simu.out>obs)+1)/(n.simu+1))
hist(simu.out,breaks=10,main=paste('permu =',n.simu,'\np-value =',round(p.value,3)),xlab='Number of human orthologs with Alzheimer GWAS',ylab='Frequency');
abline(v=obs,col='red',lwd=2)


##############################################################
# the 7 genes used in RNAi validation:
# 1nd RNAi: misfire (FBgn0266757), Sodh-1 (FBgn002489), Eglp4 (FBgn0034885), GckIII (FBgn0266465). 
# 2nd RNAi: Eglp2 (FBgn0034883), CG6984 (FBgn0034191), Spel (FBgn0015546)
gene7=c('FBgn0266757','FBgn0024289','FBgn0034885','FBgn0266465','FBgn0034883','FBgn0034191','FBgn0015546');
sum(gene7 %in% fly.gene.with.human.orthologs.df$`Search Term`) #all exist
tmp=fly.gene.with.human.orthologs.df[fly.gene.with.human.orthologs.df$`Search Term` %in% gene7,] #one-to-one orthologs

rownames(tmp)=tmp$FlyBaseID
tmp[gene7,]$FlyBaseID
tmp[gene7,]$`Human Symbol`


#df.gwas$rank=rank(df.gwas$`pvalue=(1+ngreater)/(1+nperm)`,tie='average')
df.gwas$rank=rank(df.gwas$`pvalue=(1+ngreater)/(1+nperm)`,tie='min')
rownames(df.gwas)=df.gwas$genename
df.gwas[gene7,]$rank

# use GSEA to test if these 7 genes are randomly distributed in the ranked gene list
# manual: https://bioconductor.org/packages/release/bioc/vignettes/fgsea/inst/doc/fgsea-tutorial.html
library(fgsea)
library(data.table)
library(ggplot2)
score=df.gwas$`pvalue=(1+ngreater)/(1+nperm)`
names(score)=df$genename

score[gene7]
rank(score)[gene7]

score= -log(score,base=10)
score[gene7]

input.pathways=list('AD'=gene7);
fgseaRes=fgsea(pathways=input.pathways,
      stats=score,minSize = 5,maxSize = 5000,nperm = 1000)
fgseaRes

plotEnrichment(input.pathways[["AD"]],
               score) + labs(title="7 RNAi genes")

plot.new()
plotGseaTable(input.pathways["AD"], score, fgseaRes, 
              gseaParam = 0.5)
