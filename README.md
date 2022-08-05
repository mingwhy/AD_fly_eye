
# Image analysis for AD fly eye phenotype

**Contributors**

- Ming Yang mingy16@uw.edu
- Matthew Zinkgraf zinkgrm@wwu.edu

This folder contains all analyses scripts and R markdown files used in the manuscript xxxx(TBD).

In our manuscript, we used fly as a human Alzheimer's disease model and examined the impact of the natural genetic variation in the Drosophila Genetic Reference Panel (DGRP) on the two pathogenic proteins, Abeta & Tau, induced fly eye ommatidial degenerations. 

We generated a double transgenic fly expressing the two human pathogenic proteins involved in Alzheimer's disease in the fly eyes.

We crossed DGRP lines to transgenic flies and collected F1 progenies and experimentally confirmed the expression of the two proteins in these progenies. All F1 progenies derived half of their genetic background from the parental DGRP line, dominant background effects on the fly eye degeneration phenotype were assessed.

In data analysis part, we implemented an automated pipeline in the R programming environment to process eye iamges and output eye quantitative features reflecting eye degeneration level.

We carried out a gene-level GWAS analysis to identify candidate fly genes as modifiers of fly eye degeneration. 

We compared out gene list to human genes which were related to Alzheimer's disease in previous studies and looked for biological signals as nominating biological functions or pathways that were most likly invovled in Alzheimer's disease pathogenesis.


Our results demonstrate the feasibility of utilizing natural genetic variation to identify genes that modify disease-related phenotypes and also caution about certain issues in such studies.


# Overview
- 00_fly_eye_pat
- 01_fly_eye_features
- 02_AD_fly_eye

## 00_fly_eye_pat

run script `00_fly_eye_pat.R`

The whole dataset of DGRP eye screening images is 16GB size.

In this github folder, I put a subset of eye images for demonstration considering the file size.

All raw images are available upon request.

We implemented an automated eye image analysis pipeline using R programing language.

A brief description of this pipeline can be found in the README.md file in the folder `00_fly_eye_pat`.

A detailed step-by-step tutorial on this pipeline can be found [here](https://htmlpreview.github.io/?https://github.com/mingwhy/AD_fly_eye/blob/main/00_fly_eye_pat/Fly.eye.pat_step-by-step_tutorials/Fly.eye.pat_step-by-step_tutorial_1_image.html)
 or `fly_eye_pat_step-by-step_tutorial_1_image.html` file in the `./00_fly_eye_pat/fly_eye_pat_step-by-step_tutorials` folder.


A example workflow processing 6 eye images and extracting eye scores  can be found [here](https://htmlpreview.github.io/?https://github.com/mingwhy/AD_fly_eye/blob/main/00_fly_eye_pat/Fly.eye.pat_step-by-step_tutorials/Fly.eye.pat_step-by-step_tutorial_6_image.html) or `fly_eye_pat_step-by-step_tutorial_6_image.html` file in the `./00_fly_eye_pat/fly_eye_pat_step-by-step_tutorials` folder.


After the above R script is done, run the two perl scripts to extract quantitive features based on basic measurements.

```bash
$ cd ./00_fly_eye_pat/eye.image.processed/
$ perl ../get-nn-mean-sd.pl batch1/ >batch1-nn-out.txt &
$ perl ../get-area-mean-sd.pl batch1/ >batch1-area-out.txt &

$ perl ../get-nn-mean-sd.pl batch2/ >batch2-nn-out.txt &
$ perl ../get-area-mean-sd.pl batch2/ >batch2-area-out.txt &

$ perl ./get-nn-mean-sd.pl batch3/ >batch3-nn-out.txt &
$ perl ./get-area-mean-sd.pl batch3/ >batch3-area-out.txt &
```


Files containing quantitive features of all fly eye images are stored in the folder: `./00_fly_eye_pat/eye.image.processed/*txt`


## 01_fly_eye_features

A detailed r markdown file of this step can be found [here](http://htmlpreview.github.io/?https://github.com/mingwhy/AD_fly_eye/blob/main/01_fly_eye_features/01_get.eye.features.html) or `01_get.eye.features.rmd` file in the `01_fly_eye_features` folder.

## 02_AD_fly_eye

A detailed r markdown file of this step can be found [here](http://htmlpreview.github.io/?https://github.com/mingwhy/AD_fly_eye/blob/main/02_AD_fly_eye/02_AD_fly_eye.html) or `02_AD_fly_eye.rmd` file in the `02_AD_fly_eye` folder.



