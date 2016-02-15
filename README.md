---
title: "dataAnalysisPractice.Rmd"
author: "Isabel M. Izquierdo Martin"
date: "14/02/2016"
output: html_document
---
SCRIPT: dataAnalysisPractice.Rmd

AUTHOR: Isabel M. Izquierdo Martin (imim)

DATE: 14/02/2016

OUTPUT: dataAnalysisPractice.md, dataAnalysisPractice.html files plus figures directory with the images 

PURPOSE: Report answering some questions about "activity" data

DATA SOURCE: https://archive.ics.uci.edu/ml/machine-learning-databases/00320/student.zip

INPUT DATA: student-por.csv, student-mat.csv

LIMITATIONS: ./datosExample directory must exists

EXECUTION: processing the R markdown file with knit2html() function in R
             (from the knitr package) by running the function within Rstudio

# Showing only the code

Ejemplo que muestra el código y esconde los resultados, mensajes, warning y errores
```{r versioninfo, echo=TRUE, results='hide', message=FALSE, warning=FALSE, error=FALSE}
sessionInfo()
```

# Showing the code and the results

## Establecer y obtener directorio de trabajo

Ejemplo que muestra el código y los resultados después de cada línea de código

```{r dirtrabajo, echo=TRUE, results='asis', message=FALSE, warning=FALSE, error=FALSE}
getwd()
setwd("/Users/imim/Documents/Docu13/Master-BigData-UPSA/UPSA.Analisis_datos_con_R/Practica")
getwd()
```

```{r downloadfile, echo=TRUE, results='asis', message=FALSE, warning=FALSE, error=FALSE}
# En los R chunks de código, los comentarios comienzan con #, como en cualquier script R

fileURL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00320/student.zip"
download.file(fileURL,destfile="./datosExample/student.zip",method="curl")
unzip("./datosExample/student.zip", exdir="./datosExample")
list.files("./datosExample")
fechaDescarga <- date()
fechaDescarga
```

# In order to print tables in the report
```{r printhead, echo = TRUE, results="asis"}
library(knitr) # To use kable() function

studentMat <- read.table("./datosExample/student-mat.csv", 
                         row.names=NULL, sep=";", header=TRUE)
kable(head(studentMat[,1:5]))

``` 
# Printing tables as images with textplot
 
Cuando se imprimen figuras, se indica el tamaño de las mismas.
textplot() imprime tablas como si fueran figuras

```{r conreadcsv2plot, echo=FALSE, results='asis', message=FALSE, warning=FALSE, error=FALSE,fig.width=5,fig.height=4}
library(gplots) # To use textplot()
con <- file("./datosExample/student-por.csv","r")
studentPor <- read.csv2(con)
close(con)
textplot(kable(head(studentPor[,1:5])))
```

# Show code results wihtin a text paragraph

The mean of traveltime por portuguese estudents is `r mean(studentPor$traveltime, na.rm=TRUE)`.
