# Tutorial "Cómo seleccionar variables"

pacman::p_load('tidyverse')

# NOTA: algunas de las funciones que permiten seleccionar variables son:

# - everything()
# - last_col()
# - starts_with()
# - ends_with()
# - contains()
# - matches()
# - num_range()
# - where()

mpg %>%
    select(everything()) %>% # La función everything permite seleccionar todas las columnas de un marco de datos.
    glimpse()

mpg %>%
    select(manufacturer, cyl, everything()) %>% # Con razón se preguntará por qué necesita tal función. Un caso de uso es reubicar columnas con everything. Por ejemplo, podríamos mover la columna cyl y manufacturer al comienzo del marco de datos.
    glimpse()

mpg %>%
    select(last_col()) %>% # Con la función last_col puede seleccionar la última columna en un marco de datos
    glimpse()

mpg %>%
    select(!last_col()) %>% # Incluyendo ! se puede seleccionar todas las columnas excepto la última.
    glimpse()

mpg %>%
    select(last_col(1)) %>% # Puede usar last_col para seleccionar la columna n desde la última columna. En R, el índice comienza con 0, por lo que el número 1 indica la penúltima columna.
    glimpse()

mpg %>%
    select(starts_with('m')) %>% # Podríamos usar "starts_with" para seleccionar todas las columnas que comienzan con la letra "m".
    glimpse()

mpg %>%
    select(ends_with(c('l', 'r'))) %>% # Se seleccionan las columnas que finalizan con "l" y "r".
    glimpse()

mpg %>%
    select(contains('m')) %>% # Se pueden seleccionar todas las columnas que contengan la letra “m”. Tenga en cuenta que no funciona con expresiones regulares, sino que busca exactamente la cadena que especifique. Sin embargo, de forma predeterminada, la función no distingue entre mayúsculas y minúsculas. No importa si sus columnas están en mayúsculas o minúsculas.
    glimpse()

mpg %>%
    rename(Manufacturer = manufacturer) %>%
    select(contains('m', ignore.case = FALSE)) %>% # Como contains no distingue entre minúsculas y mayúsculas, si le preocupa la distinción entre mayúsculas y minúsculas, establezca el argumento ignore.case en FALSE (esto también funciona con starts_with, end_with y matches).
    glimpse()

billboard %>%
    select(matches('\\d')) %>% # A diferencia de contains, matches funciona con expresiones regulares. Aquí, se seleccionan todas las columnas que contienen un número. La expresión regular \\d en la función representa cualquier dígito.
    colnames()

billboard %>%
    select(matches('wk\\d{1}$')) %>% # De manera similar a lo anterior, uno podría buscar solo columnas que comiencen con la cadena "wk" y estén seguidas por un solo dígito. Aquí, las llaves {} indican que estamos buscando solo un dígito, y el signo de dólar $ indica que la columna debe terminar con ese dígito.
    colnames()

# NOTA:  A partir de los tres últimos ejemplos anteriores, debería ser obvio que matches proporcionan la forma más versátil de seleccionar columnas entre las funciones tidyselect.

anscombe %>%
    select(matches('[xy][1-2]')) %>% # Si se quisieran seleccionar las columnas que comiencen con la letra x o y, y luego sigan con los dígitos 1 a 2. Aquí, los corchetes [] se utilizan para buscar conjuntos de caracteres. El primer paréntesis indica que estamos buscando la letra x o y. Si ponemos un guión - entre los caracteres, estamos buscando un rango de valores. Aquí estamos buscando números entre 1 y 2.
    glimpse()

anscombe %>%
    select(num_range('x', 1:2)) %>% # La función num_range es útil si los nombres de sus columnas siguen un patrón determinado. En el marco de datos de Anscombe, los nombres de las columnas comienzan con una letra y luego van seguidos de un número. Intentemos usar num_range con este marco de datos y encontrar todas las columnas que comienzan con la letra x y van seguidas de los números 1 o 2.
    glimpse()

billboard %>%
    select(num_range('wk', 1:15)) %>% # La misma idea se puede aplicar al conjunto de datos billboard. En este conjunto de datos tenemos una lista de columnas que comienzan con las letras "wk" (para la semana) y los números del 1 al 76.
    glimpse()

billboard %>%
    select(where(is.character)) %>% # where se utiliza cuando desea seleccionar variables de un determinado tipo de datos. Por ejemplo, podríamos seleccionar variables de tipo carácter. Otras funciones de predicado son: is.double, is.logical, is.factor y is.integer
    glimpse()

mpg %>%
    select(where(is.character) & contains('l')) %>% # También puede combinar las diferentes funciones de selección con los operadores & y |. Aquí, se seleccionaron todas las columnas que son de tipo carácter y que contienen la letra l
    glimpse()
