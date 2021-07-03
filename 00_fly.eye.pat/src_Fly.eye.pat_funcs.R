# the original fviz_contrib function in 'factoextra' package was modified,
# line: geom_hline(yintercept=theo_contrib, linetype=2, color="red") 
# was commmented out.
# I renamed this function to be 'ming_fviz_contrib'.
# The original function can be accessed here: https://github.com/kassambara/factoextra/blob/master/R/fviz_contrib.R
ming_fviz_contrib <- function(X, choice = c("row", "col", "var", "ind", "quanti.var", "quali.var", "group", "partial.axes"),
                         axes=1, fill="steelblue", color = "steelblue", 
                         sort.val = c("desc", "asc", "none"), top = Inf,
                         xtickslab.rt = 45, ggtheme = theme_minimal(), ...)
{

  sort.val <- match.arg(sort.val)
  choice = match.arg(choice)
  
  #title <- .build_title(choice[1], "Contribution", axes)

  dd <- facto_summarize(X, element = choice, result = "contrib", axes = axes)
  contrib <- dd$contrib
  names(contrib) <-rownames(dd)

  # expected Average contribution
  theo_contrib <- 100/length(contrib)
  if(length(axes) > 1) {
    # Adjust variable contributions by the Dimension eigenvalues
    eig <- get_eigenvalue(X)[axes,1]
    theo_contrib <- sum(theo_contrib*eig)/sum(eig)
  }
  df <- data.frame(name = factor(names(contrib), levels = names(contrib)), contrib = contrib, stringsAsFactors = TRUE)
  
  # Define color if quanti.var
  if(choice == "quanti.var") {
    df$Groups <- .get_quanti_var_groups (X)
    if(missing(fill)) fill <- "Groups"
    if(missing(color)) color <- "Groups"
  }
  
  p <- ggpubr::ggbarplot(df, x = "name", y = "contrib", fill = fill, color = color,
                         sort.val = sort.val, top = top,
                         #main = title, 
                         ylab = FALSE, xlab ="Contributions (%)",
                         xtickslab.rt = xtickslab.rt, ggtheme = ggtheme,
                         sort.by.groups = FALSE, ...
                         )#+
    #geom_hline(yintercept=theo_contrib, linetype=2, color="red")
  
#   p <- .ggbarplot(contrib, fill =fill, color = color,
#                   sort.value = sort.val[1], top = top,
#                   title = title, ylab ="Contributions (%)")+
#     geom_hline(yintercept=theo_contrib, linetype=2, color="red")

  p
}

# calculate mean and sd removing 3 largest and 3 smallest values
get_mean_sd <- function(x){
  x=sort(x);
  x=x[-c(1,2,3)];
  x=sort(x,decreasing=TRUE);
  x=x[-c(1,2,3)];
  x.mean=mean(x);
  x.sd=sd(x)
  return(c(x.mean,x.sd))
}
# resize function
resFunc <- function(x) {
  small=dim(x)[1]/4;
  if(small<640){size=dim(x)[1]}
  else{size=small}
  resize(x, size)
}
# Store RGB into data frame
RGBintoDF <- function(x) {
  imgDm <- dim(x)
  #Assign original image RGB channels to data frame
  imgOri <- data.frame(
    x = rev(rep(imgDm[1]:1, imgDm[2])),
    y = rev(rep(1:imgDm[2], each = imgDm[1])),
    R = as.vector(x[,,1]),
    G = as.vector(x[,,2]),
    B = as.vector(x[,,3])
  )
  return(imgOri)
}
# Store Gray channel into data frame
GintoDF <- function(x) {
  imgDm <- dim(x)
  #Assign original image RGB channels to data frame
  imgOri <- data.frame(
    x = rev(rep(imgDm[1]:1, imgDm[2])),
    y = rev(rep(1:imgDm[2], each = imgDm[1])),
    G = as.vector(x)
  )
  return(imgOri)
}
# White TopHat morphological transform
wTopHat <- function(x, y=2, z='diamond'){
  imgGrey <- channel(x, "green")
  imgTop <- whiteTopHat(imgGrey,kern=makeBrush(y, shape = z))
}
# Display images
dispImg <- function(x) {
  display(x, method="raster")
}
# Select pixels with intensity > 0.99 quantile
dispImgT <- function(x, y) {
  display(x > quantile(x, y), method="raster")
}
# Add ellipse to plot
ellPlot <- function(z, w) {
  p <- ggplot(z, aes(x, y)) +
    geom_point() +
    labs(title = "Selected pixels") +
    stat_ellipse(level=w) +
    plotTheme()
  return(p) }
# Create image from ROI
roitoImg <- function(z) {
  R <- xtabs(R~x+y, z)
  G <- xtabs(G~x+y, z)
  B <- xtabs(B~x+y, z)
  imgROI <- rgbImage(R, G, B)
  return(imgROI)
}
# ggplot theme to be used
plotTheme <- function() {
  theme(
    panel.background = element_rect(
      size = 2,
      colour = "black",
      fill = "white"),
    axis.text.x = element_text(
      face="bold", color="#993333", 
      size=5, angle=0),
    axis.text.y = element_text(
      face="bold", color="#993333", 
      size=5, angle=0),
    axis.ticks = element_line(
      size = 1),
    panel.grid.major = element_line(
      colour = "gray80",
      linetype = "dotted"),
    panel.grid.minor = element_line(
      colour = "gray90",
      linetype = "dashed"),
    axis.title.x = element_text(
      size = rel(0.5),
      face = "bold"),
    axis.title.y = element_text(
      size = rel(0.5),
      face = "bold"),
    plot.title = element_text(
      size = 5, #size = 20,
      face = "bold",
      hjust = 0.5)
  ) }
  