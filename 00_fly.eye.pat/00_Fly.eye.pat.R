# April 01, 2021 
# Ming Yang -- mingy16@uw.edu
# Fly.eye.pat is an automated images analysis pipeline implemented in **R**  to score fly eye images based on ommatidia regularity pattern.
# modify code between line 20 and 23 to let the script konw where to read in images and where to put processed files and results.

# In this github folder, I put a subset of eye images as the whole DGRP eye screen image file is ~16GB big.
# All raw iamges are available upon request
#################
# Load packages #
#################
library(lattice)
library(ggplot2)
library(sp) 
library(raster) 
library(tiff)
library(EBImage)
library(Gmedian)
library(gridExtra)

#######################################################
# source helpful R code and specify image folder path #
#######################################################
source('./src_Fly.eye.pat_funcs.R') #load helpful functions for plotting
dir.in='./eye.image.raw/' #input raw image folder 
dir.out='./eye.image.processed/' #output folder

if(!dir.exists(dir.out)){dir.create(dir.out)} #if the output folder didn't exist, create one
cat("check dir: ",dir.in,"; dirout",dir.out,"\n");

##############################
# Read in images and process #
##############################
# there are three batches, each contains a bunch of DGRP lines
# 5623 images were preocessed within 24hrs using one core on mac
batch.dir=Sys.glob(paste0(dir.in,'/batch*'))

for(batch in batch.dir){
  #line.dir=Sys.glob(paste0(batch,'/RAL_*'))
  line.dir=Sys.glob(paste0(batch,'/*'))
  out.batch.dir=paste0(dir.out,basename(batch))
  if(!dir.exists(out.batch.dir)){dir.create(out.batch.dir)}
  
  for(line in line.dir){
    image.filenames <- list.files(path=line,pattern="*jpg$", full.name=F)
    cat('there are',length(image.filenames),'in',line,"\n");
    
    n.images=length(image.filenames);
    image.files=paste(line,image.filenames,sep='/');
    
    out.line.dir=paste0(out.batch.dir,'/',basename(line),'/')
    if(!dir.exists(out.line.dir)){dir.create(out.line.dir)}
    
    # process one image at a time
    for(image.i in 1:n.images){
      image = readImage(image.files[[image.i]] )
      image.name = image.filenames[image.i]
      cat('begin processing image',image.name,',',image.i,'out of',n.images,' images in this group\n')
      
      output.plot.name=paste0(out.line.dir,"/",image.filenames[image.i],"-roi.pdf");
      if(file.exists(output.plot.name)){next}
      
      display(image, method="raster")
      dim(image)
      
      # Resize to fit memory
      image.res=resFunc(image)
      display(image.res, method="raster")
      dim(image.res)
      
      # Assign resized images RGB channels to data frames
      image.Ori <- RGBintoDF(image.res)
      head(image.Ori)
      
      # White TopHat morphological transform
      image.Top <- wTopHat(image.res,y=5,z='diamond')
      
      # Display images
      par(mfcol=c(1,2))
      dispImg(image.res)
      dispImgT(image.Top,0.99)
      
      ## Threshold and centroids
      # Assign gray channel to data frame
      image.grey <- GintoDF(image.Top)
      head(image.grey)
      
      # Threshold to keep pixels with intensity > 0.99 quantile
      image.thres.retain<-image.grey[image.grey$G > quantile(image.grey$G,0.99), ]
      
      # select ROI, region of interest through two rounds of pixel fitering based on distances to centroids
      image.thres = image.thres.retain
      cutoffs=c(0.8,0.3);
      for(cutoff in cutoffs){
        cat('ROI selection with cutoff',cutoff,'\n')
        # Estimate images centroid
        centroids <- Weiszfeld(image.thres[,1:2])
        
        # extract each pixel x,y coordiantes retained pixels
        thresXY <- image.thres[,1:2,drop=FALSE]
        p1<-ggplot(thresXY,aes(x=x,y=y))+geom_point()+
          geom_point(aes(x=centroids$median[1], y=centroids$median[2]),colour="red",size=4)+
          theme_bw()+ ggtitle(image.name)
        ## Distances to centroide,calculate distances to centroid
        pdist <- pointDistance(p1=thresXY, p2=centroids$median,lonlat=F)
        
        # Mark distances > 0.8 quantile, as they belong to
        # points outside the eye boundary in their majority
        pLogic <- (pdist < quantile(pdist, cutoff));
        distCent <- cbind(distCent = pdist, selected = pLogic)
        
        # Plot example histograms
        p2<-ggplot(data.frame(distCent),aes(x=distCent))+geom_histogram()+
          geom_vline(xintercept = quantile(distCent[,1], cutoff),col="red",lty="dashed", lwd=2)+
          theme_bw()+ ggtitle(image.name)
        
        
        # Join thresholded and distances lists
        thresDist <- cbind(image.thres,distCent);
        # retain points with distance < quantile cutoff 0.8
        distSelect <- thresDist[thresDist$selected==1,]
        
        # Plot examples (black clouds with blue roi overlay)
        p3 <- ggplot(data=thresDist, aes(x=x, y=y,color=selected))+
          geom_point(show.legend = FALSE) + 
          theme_bw()+ ggtitle(image.name)
        
        grid.arrange(p1,p2,p3,ncol=3)
        
        # Overlay to image and plot example
        p <- ggplot(data = image.Ori, aes(x = x, y = y)) +
          geom_point(colour = rgb(image.Ori[c("R","G","B")])) +
          labs(title = "Original Eye selected Points",
               cex=0.5) +xlab("x") +ylab("y") +
          geom_point(data=distSelect, alpha=0.2) +
          plotTheme()
        
        image.thres <- distSelect[,1:3]
      }
      
      ## Subset and confidence ellipse and Add ellipse to plot 
      ellPlots = ellPlot(distSelect,0.90)
      ellPlots #it's a ggplot object
      # Extract components
      build = ggplot_build(ellPlots)$data
      ell = build[[2]]
      
      # Select original image points inside ellipse
      orig.ell = data.frame(image.Ori[,1:5],
                            in.ell = as.logical(point.in.polygon(image.Ori$x,image.Ori$y, ell$x, ell$y)))
      orig.pix = orig.ell[orig.ell$in.ell==TRUE,]
      
      # plot example
      p <- ggplot(data = image.Ori, aes(x = x, y = y)) +
        geom_point(colour = rgb(image.Ori[c("R", "G","B")])) +
        labs(title = "Original Eye final ROI", cex=0.5) +
        xlab("x") + ylab("y") +
        geom_polygon(data=ell[,1:2], alpha=0.2,
                     size=1, color="blue") +
        plotTheme()
      print(p)
      
      ## Create image from final ROI
      rois.image = roitoImg(orig.pix)
      display(rois.image,method='raster'); #check image
      
      ## begin extract ommatidia configuration features
      pic=rois.image
      #hist(pic);grid()
      
      y = equalize(pic)
      #hist(y);grid()
      #display(y, title='Equalized Grayscale Image',method='raster')
      
      grayimage<-channel(y,"grey")
      #display(grayimage,method='raster')
      nmask = thresh(grayimage, w=5, h=5, offset=0.02); #display(nmask)
      nmask = opening(nmask, makeBrush(3, shape='disc')); #display(nmask)
      nmask = fillHull(nmask); #display(nmask)
      nmask = bwlabel(nmask)
      cat("Number of ommatidia,",max(nmask),"\n");
      
      # get raw measurements on each ommatidium
      fts = data.frame(computeFeatures.moment(nmask))
      #head(fts)
      fts2 <- data.frame(computeFeatures.shape(nmask))
      #head(fts2)
      
      # output plots for manual inspection
      #pdf(paste0(out.line.dir,"/",image.filenames[image.i],"-roi.pdf"));
      pdf(output.plot.name)
      par(mfrow=c(1,5));
      display(pic,"raster")
      display(y, title='Equalized Grayscale Image',method='raster')
      display(grayimage,method='raster')
      display(nmask,"raster");
      display(nmask,"raster");
      text(fts[,"m.cx"], fts[,"m.cy"], 
           labels=seq_len(nrow(fts)), col="red", cex=0.8)
      dev.off();
      
      # output quantitative measurements for this image
      out1.name=paste(out.line.dir,"/",image.filenames[image.i],"-coord.txt",sep='');
      out2.name=paste(out.line.dir,"/",image.filenames[image.i],"-area.txt",sep='');
      write.table(fts,file=out1.name,quote=F,row.names = F);
      write.table(fts2,file=out2.name,quote=F,row.names = F);
    }
  }
}
