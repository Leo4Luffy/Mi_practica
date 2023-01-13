# Tutorial "Cómo leer muchos archivos en R"

# NOTA: No siempre se lee un solo archivo en R. No es raro que sus datos estén dispersos en cientos o miles de archivos. Por supuesto, no se desea leer estos archivos en R manualmente. Por lo tanto, necesita un método automático para leer archivos.

pacman::p_load('tidyverse', 'fs')

## 1. Se crean múltiples archivos ----

dir_create(c('./01_Improve reading files/many_files')) # Se crea un nuevo directorio llamado many_files donde se almacenarán los archivos CSV que se usaran en el ejemplo.

mpg_samples <- map(1:25, ~ slice_sample(mpg, n = 20)) # Se crean 25 archivos CSV, muestreando 20 filas del conjunto de datos mpg 25 veces.

iwalk(mpg_samples, ~ write_csv(., paste0('./01_Improve reading files/many_files/', .y, '.csv')))

## 2. Creación de un vector de caracteres de rutas de archivos ----

(csv_files_list_files <- list.files(path = './01_Improve reading files/many_files', pattern = 'csv', full.names = TRUE)) # Se crea inicialmente un vector de caracteres de las rutas de los archivos usando la función base del R list.files, que devuelve vectores de caracteres de los nombres de los archivos en un directorio. La función list.files tiene varios argumentos. Con path, se especifica dónde encontrar sus archivos. pattern recibe una expresión regular. En este caso, dijimos que el archivo debería contener la cadena “csv”. Finalmente, el argumento full.names indica que queremos almacenar las rutas completas de los archivos, no solo los nombres de los archivos. Si no establece este argumento en TRUE, tendrá problemas para leer sus archivos más adelante.

(csv_files_dir_ls <- dir_ls(path = './01_Improve reading files/many_files/', glob = '*.csv', type = 'file')) # Otra forma de crear un vector de caracteres. Se usa la función dir_ls del paquete fs, que proporciona una interfaz multiplataforma para acceder a archivos en su disco duro. Esta admite todas las operaciones de archivo (eliminación, creación de archivos, movimiento de archivos, etc.).

## 3. Lectura de los archivos en R desde un vector de caracteres de rutas ----

data_frames <- map_dfr(csv_files_dir_ls, ~ read_csv(.x, show_col_types = FALSE)) # Conociendo la ruta de los archivos, se pueden cargar los archivos en R. La forma tidyverse de hacerlo es usar la función map_dfr del paquete purrr. map_dfr recorre todas las rutas de archivo y vincula los marcos de datos en un solo marco de datos. El .x en el siguiente código representa el nombre del archivo.

glimpse(data_frames)

#data_frames <- map_dfr(csv_files_dir_ls, ~ read_csv(.x, , show_col_types = FALSE) %>%
    #mutate(filename = .x)) %>% # Un buen truco es especificar un argumento de identificación que agregue una nueva columna al marco de datos que indique de qué archivos provienen los datos.
    #glimpse()

data_frames_2 <- read_csv(csv_files_dir_ls, id = 'filename', show_col_types = FALSE) %>% # Otro enfoque es usar la función read_csv directamente colocando el vector de caracteres de los nombres de archivo directamente en read_csv. 
    glimpse

## 4. Si los nombres de las columnas de los archivos no son consistentes ----

mpg_samples <- map(1:10, ~ slice_sample(mpg, n = 20))

inconsistent_dframes <- map(mpg_samples, ~ janitor::clean_names(dat = .x, case = 'random')) # Desafortunadamente, vivimos en un mundo desordenado. No todos los nombres de columna son iguales. Vamos a crear un conjunto de datos desordenado con nombres de columna inconsistentes.

map(inconsistent_dframes, ~ colnames(.x)) %>%
    head(10) # Los nombres de columna de estos 10 marcos de datos consisten en los mismos nombres, pero se escriben aleatoriamente en mayúsculas o minúsculas.

inconsistent_dframes <- map(inconsistent_dframes, ~ .x[sample(1:length(.x), sample(1:length(.x), 1))]) # Para hacer que el conjunto de datos anterior sea aún más complicado, seleccionamos un conjunto aleatorio de columnas por marco de datos.

map(inconsistent_dframes, ~ colnames(.x)) %>%
    head(10)

dir_create(c('./01_Improve reading files/unclean_files'))

iwalk(inconsistent_dframes, ~ write_csv(.x, paste0('./01_Improve reading files/unclean_files/', .y, '.csv'))) # Se guardan los 10 marcos de datos creados anteriormente.

many_columns_data_frame <- dir_ls(path = './01_Improve reading files/unclean_files/', glob = '*.csv', type = 'file') %>%
    map_dfr(~ read_csv(.x, name_repair = tolower, show_col_types = FALSE) %>% # El último truco es limpiar los marcos de datos y se convierten los nombres de columna a una convención de nomenclatura específica. Los escribimos todos en minúsculas y se unen.
    mutate(filename = .x)) %>% 
    glimpse()
