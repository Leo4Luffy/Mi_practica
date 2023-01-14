# Tutorial "Cómo mejorar la lectura de archivos con las funciones read_*"

pacman::p_load('tidyverse', 'janitor')

mpg_new <- read_csv('Datos/mpg_uppercase.csv', show_col_types = FALSE) %>% # Es raro leer un archivo CSV sin ninguna limpieza de datos. Supongamos que quiero convertir los nombres de las columnas de este archivo CSV a minúsculas y seleccionar solo las columnas que comienzan con la letra "m".
    clean_names() %>% # Esta es una función del paquete janitor.
    select(c(manufacturer, model)) %>%
    glimpse()

# NOTA: El enfoque anterior está perfectamente bien. Sin embargo, resulta que las funciones read_* tienen algunos argumentos de limpieza de datos incorporados. Estos argumentos no le permiten hacer algo nuevo, pero sí le permiten encapsular la lectura de los datos con la limpieza de datos.

## 1. Convertir nombres de columnas a minúsculas ----

read_csv('Datos/mpg_uppercase.csv', show_col_types = FALSE, name_repair = make_clean_names) %>% # Dentro de read_csv con la función make_clean_names para el argumento name_repair se pueden convertir los nombres de las columnas a miniscúlas.
    glimpse()

## 2. Reemplazar y eliminar cadenas de caracteres en los nombres de sus columnas ----

make_clean_names(c('A', 'B%', 'C'), replace = c('%' = '_percent')) # Con make_clean_names también puede reemplazar ciertos caracteres de los nombres de las columnas. Supongamos que queremos reemplazar el carácter “%” con la palabra “_percent”.

make_clean_names(c('A_1', 'B_1', 'C_1'), replace = c('^A_' = 'a')) # Si está familiarizado con las expresiones regulares, puede realizar reemplazos más complejos. Por ejemplo, podría eliminar el guión bajo de todos los nombres de columna que comienzan con la letra "A".

## 3. Uso de una convención de nomenclatura específica para nombres de columnas ----

make_clean_names(c('myHouse', 'MyGarden'), case = 'snake') # Con make_clean_names se convirtien los nombres de las columnas a minúsculas. Esto se debe a que la función usa la convención de nomenclatura de snake de forma predeterminada. Snake convierte todos los nombres a minúsculas y separa las palabras con un guión bajo.

make_clean_names(c('myHouse', 'MyGarden'), case = 'none') # Si no desea cambiar la convención de nomenclatura de los nombres de sus columnas, use none en case.

read_csv('Datos/mpg_uppercase.csv', show_col_types = FALSE, name_repair = ~ make_clean_names(., case = 'upper_camel')) %>% # Aquí un ejemplo usando upper_camel al momento de importar los datos. El punto . en make_clean_names denota el vector de nombres de columna.
    glimpse()

## 4. Selección de columnas específicas ----

read_csv('Datos/mpg_uppercase.csv', show_col_types = FALSE, name_repair = make_clean_names, col_select = c(manufacturer, model)) %>% # Además de limpiar los nombres de las columnas, también puede seleccionar columnas directamente desde read_csv usando el argumento col_select.
    glimpse()
