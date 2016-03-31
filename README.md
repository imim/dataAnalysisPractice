---
title: "Practica de Análisis de datos con R"
author: "Abiel Guillermo Flores Buezo"
date: "3/22/2016"
output: html_document
always_allow_html: yes
---

# Práctica de analisis de datos con R

```{r echo=FALSE}
library(reshape)
library(ggvis)
library(knitr)
sessionInfo()
```

## Introducción

Esta es una práctica de análisis y visualización de datos utilizando __RStudio__, y el modulo __knitr__ del mismo.
Para llevarla a cabo, haré uso del siguiente dataset [Student Performance Data Set](https://archive.ics.uci.edu/ml/machine-learning-databases/00320/student.zip) cuya información puede ser encontrada [aquí](https://archive.ics.uci.edu/ml/datasets/Student+Performance).

Lo primero que debemos hacer es situarnos en eldirectorio de trabajo que vamos a utilizar. Para establecer nuestro directorio de trabajo utilizamos el comando `setwd("/home/rstudio/dataAnalysisPractice")`. Si queremos saber cual es el directorio de trabajo en el cual nos encontramos ejecutamos el comando `getwd()`.

Los archivos de datos son los siguientes:
```{r echo=FALSE, results='hold'}
for (v in list.files("data")) {
  print(v)
}
remove(v)
```

`student-mat.csv` y `student-por.csv` son los archivos que nos interesan, ya que contienen los datos. `student-merge.R` es un Rscript para juntar los datos de los anteriores archivos, pero no lo haremos de esa manera. Finalmente `student.txt` contiene la descripción de los datos en los primeros dos archivos.

## Lectura de datos

Ya que los archivos a los que vamos a acceder tienen formato _CSV_, sabemos que los valores están "ordenados" y separados por algún tipo de separador. Si echamos un vistazo en los archivos, veremos que el separador utilizado es el punto y coma (__;__). En este punto podríamos utilizar diversos métodos, pero R cuenta con el comando `read.csv`, el cual leerá estos datos y creará un dataframe a partir de ellos:

```{r echo=TRUE, results='hide'}
dt.students.mat <- read.csv("./data/student-mat.csv", header=TRUE, sep = ";", quote="\"")
dt.students.por <- read.csv("./data/student-por.csv", header=TRUE, sep = ";", quote="\"")
```

Con los parámetros que pasamos, le indicamos varias cosas. En concreto, que la primera linea de el archivo contiene los nombres de los campos en esas posiciones, y que deseamos que las reconozca así, que el separador es el _punto y coma_, y que algunos campos (sobre todo los campos de tipo cadena de caracteres) están entre _comillas dobles_.

Ahora disponemos de dos dataframes, uno con los alumnos en la clase de matematicas, y otro con los alumnos en la clase de portugués.

Cada dataframe creado consta de 33 columnas, o _variables_. Esta es una muestra de los datos a los que nos enfrentamos en la clase de matemáticas, con solo 10 _variables_:

```{r}
head(dt.students.mat[1:10])
```


## Preparación y transformación de datos

Los datos no siempre están ordenados o son útiles cuando nos los entregan.
Estos datos en su estado bruto pueden contar de varios inconvenientes: falta de valores, tipos de datos incorrectos, unidades de medida incompatibles, codificado de variables incorrecto, etc...
En estas situaciónes es necesario que preparemos y transformemos los datos para que puedan ser utilizados en el análisis de datos que estamos por ejecutar.
Este proceso tiene varios nombres. Los más sonados _Data Munging, Data Cleaning, Data Cleansing, Data Wrangling_... Y consta de tareas como las siguientes:

- Renombrar variables
- Convertir tipos de dato
- Codificar valores
- Juntar datasets
- Convertir unidades
- Hacer algo con los valores que faltan
- Hacer algo con los valores anomalos o sin sentido
- etc...

Afortunadamente los datasets de los que constamos están más bien limpios, y no necesitamos realizar muchos cambios. Y como nos interesa hacer un pequeño análisis de las clases por separado, no juntaremos los datasets hasta que lo necesitemos.

Una de las cosas que podemos hacer es formatear los nombres de las columnas, para ayudar a trabajar más flexiblemente con ellas.

```{r}
names(dt.students.mat) <- tolower(names(dt.students.mat))
names(dt.students.por) <- tolower(names(dt.students.por))
names(dt.students.mat)
```

Los valores de la columna `famsize` son o bien `LE3` o `GT3`, lo cual significa que o bien la familia consta de 3 o menos integrantes, o bien consta de más de 3 integrantes. Si agregaramos valores, nosotros mismos, podríamos quitarle validez a los datos, así que es mejor que permanezcan así.


Por comprobar un poco si tenemos algún valor _NA_ podemos utilizar estos comandos para saber el número de valores _NA_ que hay en cada columna:

```{r}
# sapply(dt.students.mat, function(x) sum(is.na(x)))
# apply(is.na(dt.students.mat),2,sum)
# colSums(is.na(dt.students.mat))
sum(is.na(dt.students.mat))
```

Afortunadamente no tenemos campos vacios, y los datos están ya en un formato que se puede utilizar.

## Análisis exploratorio

Cada una de las entradas en estos datos corresponde a los datos de un alumno. Si echamos un vistazo o si relacionamos las variables entre ellas podemos obtener información interesante.

Por ejemplo. El número total de alumnos de cada escuela:

```{r echo=FALSE}
print("Numero de alumnos para cada escuela, en la clase de matemáticas:")
table(dt.students.mat$school)
print("Numero de alumnos para cada escuela, en la clase de portugués:")
table(dt.students.por$school)
```

En general hay menos alumnos en la clase de Matemáticas.

```{r}
print("Clase de matemáticas. Alumnos con dirección Rural o Urbana por escuelas:")
cast(dt.students.mat, school~address, length, value=c("g3"))
print("Clase de Portugués Alumnos con dirección Rural o Urbana por escuelas:")
cast(dt.students.por, school~address, length, value=c("g3"))

```

Hemos descubierto que la escuela "Mousinho da Silveira" tiene más alumnos que proceden de algún pueblo, probablemente rodeando la ciudad, que la escuela "Gabriel Pereira" que seguramente esté ubicada más centricamente dentro de la ciudad, o tenga mejores accesos a los transportes de la misma.

Otro sitio donde podemos fijar nuestra mirada es en las variables correspondientes al tiempo que le toma al alumno llegar a la escuela, y el tiempo de estudio de el que dispone.

La lógica nos dice que si un alumno gasta tiempo "viajando", reduce el tiempo que tiene disponible para estudiar. Veamos si esto concuerda con los datos de los que disponemos, comprobando la covarianza con `cov()`: 

- Covarianza matemáticas: `r cov(dt.students.mat$traveltime, dt.students.mat$studytime)`
- Covarianza portugués: `r cov(dt.students.por$traveltime, dt.students.por$studytime)`

La covarianza que obtenemos es negativa, lo cual significa que si el tiempo de viaje incrementa, el tiempo de estudio decrementa. Aun así necesitamos saber qué tan crítica es la relación entre estas dos variables, para lo que utilizaremos `cor()` para saber la correlación:

 - Matemáticas: `r cor(dt.students.mat$traveltime, dt.students.mat$studytime)`
 - Portugués: `r cor(dt.students.por$traveltime, dt.students.por$studytime)`
 
La correlación al ser tan baja nos indica que aunque estas variables pueden estar relacionadas, la influencia que tienen la una en la otra, no es significativa.

Vamos a continuar uniendo los dos dataframes para trabajar con uno solo. Ya que la descripción nos indica que hay unos 382 alumnos que están repetidos entre los 2 dataframes, vamos a unirlos de manera que trabajemos con esos, ya que asisten a ambas clases.

Para unir los dataframes hacemos de la siguiente manera:

```{r}
dt.students.mp = merge(dt.students.mat, dt.students.por, by = c("school", "sex",
  "age", "address", "famsize", "pstatus", "medu", "fedu", "mjob", "fjob", "reason",
  "nursery", "internet"), all=FALSE, suffixes = c('mat', 'por'))
```

## Visualización de datos

El conjunto de datos de que disponemos no es el mejor para realizar modelos, y/o predicciones. Así que el informe no irá más alla de la visualización de los datos.

El objetivo de visualizar los datos es el poder hacer más rápida la comprensión de los datos que estamos exponiendo. De manera que no sea necesario entender de "" y/o "programación".
Por ejemplo, antes hemos comparado los valores de los alumnos que asisten a cada escuela. Los alumnos están en las dos clases se distribuyen en las escuelas de la siguiente manera:

```{r}
table(dt.students.mat$school)
```

Pero si lo vemos representado entendemos la idea inmediatatamente:

```{r}
plot(dt.students.mp$school)
```

Esta es la manera más básica de representar los datos. Pero hay otras formas más atractivas de hacerlo.

```{r}
hist(x = dt.students.mat$g3, breaks = 20, xlab = "Notas finales", ylab = "Número de alumnos",
     main = "Número de alumnos de matemáticas por notas")
hist(x = dt.students.por$g3, breaks = 20, xlab = "Notas finales", ylab = "Número de alumnos",
     main = "Número de alumnos de portugués por notas")
```

Hay muchas maneras de representar los datos en R. Incluso puedes crear fácilmente una forma de hacerlo tu mismo. Personalmente, la que más me llama la atención es la librería `ggvis` que esta, en parte, basada en `ggplot2`. Veamos algunos ejemplos:

```{r}
dt.students.mp %>% 
  ggvis(x = ~absencesmat, y = ~g3mat, fill = ~traveltimemat) %>% 
  layer_points() %>% 
  add_axis("x", title = "Ausencias matemáticas") %>% 
  add_axis("y", title = "Notas finales matemáticas") %>% 
  add_legend("fill", title = "Tiempo de desplazamiento")
```


```{r}
dt.students.mp %>% 
  ggvis(x = ~absencespor, y = ~g3por, fill = ~traveltimepor) %>% 
  layer_points() %>% 
  add_axis("x", title = "Ausencias portugués") %>% 
  add_axis("y", title = "Notas finales portugués") %>% 
  add_legend("fill", title = "Tiempo de desplazamiento")
```

En los graficos anteriores observamos que las ausencias de un alumno en una clase, y sus notas finales, no se relacionan. Además de ello, estaba representado el grado del tiempo de desplazamiento hasta el centro docente, desde casa. Al igual que las otras variables, estaba distribuido sin seguir ningún patrón reconocible, así que tampoco se reaciona mucho.

Finalmente, varias capas:

```{r}
dt.students.mp %>% 
  ggvis(x = ~g2mat, y = ~g3mat, fill = ~internet) %>% 
  layer_smooths() %>% 
  layer_points() %>% 
  add_axis("x", title = "Notas Segunda Evaluación Matemáticas" ) %>% 
  add_axis("y", title = "Notas Evaluación Final Matemáticas") %>% 
  add_legend("fill", title = "Acceso a internet")
```


```{r}
dt.students.mp %>% 
  ggvis(x = ~g2por, y = ~g3por, fill = ~internet) %>% 
  layer_smooths() %>% 
  layer_points() %>% 
  add_axis("x", title = "Notas Segunda Evaluación Portugués" ) %>% 
  add_axis("y", title = "Notas Evaluación Final Portugués") %>% 
  add_legend("fill", title = "Acceso a internet")
```

Esta librería ofrece varios recursos interactivos, de manera que la información es más atractiva.
Además de esta, hay bastantes mas librerías, cada una con características únicas que pueden servir para representar debidamento la información que manejas.
Además puedes utilizar el paquete `shiny` de RStudio, el cual tiene una gran cantidad de buenas herramientas para crear aplicaciones web interactivas.
Pero todo eso (_quizá_) venga en una futura actualización de este documento.


