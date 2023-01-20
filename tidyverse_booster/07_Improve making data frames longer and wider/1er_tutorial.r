# Tutorial "Cómo alargar un marco de datos"

pacman::p_load('tidyverse')

# NOTA: suponga que recibe el siguiente conjunto de datos de un colega. Dos grupos de personas “a” y “b” tenían que indicar durante tres semanas con qué frecuencia corrían en una semana. Las columnas w-1 a w-3 representan las semanas 1 a 3:

running_data <- tribble(
    ~person, ~group, ~"w-1", ~"w-2", ~"w-3",
    "John", "a", 4, NA, 2,
    "Marie", "a", 2, 7, 3,
    "Jane", "b", 3, 8, 9,
    "Peter", "b", 1, 3, 3
    ) # Este marco de datos no está ordenado porque no todas las columnas representan variables. Según Wickham (2014), una variable contiene “todos los valores que miden el mismo atributo subyacente (como altitud, temperatura, duración) en todas las unidades)”. Sin embargo, en nuestro marco de datos, las columnas w-1, w-2 y w-3 representan valores de una semana variable subyacente que no se representa como una columna.

# NOTA: una representación ordenada de este marco de datos se vería de la siguiente manera:

running_data %>%
    pivot_longer(
        cols = 'w-1':'w-3',
        names_to = "week",
        values_to = "value"
        ) # Aquí se uso la función pivot_longer para crear este marco de datos. Se alargó el marco de datos. Un marco de datos se alarga cuando aumentamos el número de sus filas y disminuimos el número de sus columnas. Entonces, cuando ordenamos un conjunto de datos desordenado, esencialmente hacemos que el conjunto de datos sea más largo.

## Los encabezados de columna son valores de una variable, no nombres de variables ----

# NOTA: el conjunto de datos anterior (no ordenado) contiene columnas que representan valores y no nombres de variables, lo cual es un problema:

running_data %>%
    colnames()

# NOTA: para que el marco de datos anterior sea más largo y ordenado, debemos especificar argumentos para los cuatro parámetros en pivot_longer. Ejecutemos la función y veamos cómo se ven los resultados:

running_data %>%
    pivot_longer(
        cols = 'w-1':'w-3',
        names_to = "week",
        values_to = "value"
        ) # Los argumentos son data donde se coloca el marco de datos para hacer columnas más largas, columns donde se colocan las columnas que deben convertirse a un formato más largo, names_to donde se coloca el nombre de la nueva columna que contendrá los nombres de las columnas, y values_to donde se coloca el nombre de la nueva columna que contendra los valores.

# NOTA: podemos mejorar aún más este código eliminando los prefijos en la columna de la semana. w-1, por ejemplo, debe mostrarse como 1:

running_data %>%
    pivot_longer(
        cols = 'w-1':'w-3',
        names_to = "week",
        values_to = "value",
        names_prefix = "w-"
        )

# NOTA: también puede ver que la variable semana es un carácter y no un doble. Para convertir este tipo de datos podemos usar el parámetro names_transform:

running_data %>%
    pivot_longer(
        cols = 'w-1':'w-3',
        names_to = "week",
        values_to = "value",
        names_prefix = "w-",
        names_transform = as.double
        )

# NOTA: De manera similar, podría convertir el tipo de datos de la columna values_to con values_transform (un factor en este caso):

running_data %>%
    pivot_longer(
        cols = 'w-1':'w-3',
        names_to = "week",
        values_to = "value",
        names_prefix = "w-",
        values_transform = as.factor
        )

# NOTA: aquí hay otro ejemplo donde los encabezados de columna representan valores (del paquete tidyr):

relig_income # Las columnas <$10k a No sabe/Rechazado son valores de un ingreso variable subyacente. Los valores debajo de estas columnas indican la frecuencia con la que las personas informaron tener un determinado ingreso.

# NOTA: ordenemos el marco de datos anterior haciéndolo más largo:

relig_income %>%
    pivot_longer(
        cols = "<$10k":"Don't know/refused",
        names_to = "income",
        values_to = "freq"
        )

# NOTA: finalmente, otro ejemplo. El conjunto de datos billboard contiene las mejores clasificaciones de cartelera del año 2000:

billboard # Mirando las columnas, encontramos la friolera de 76 nombres de columna que son valores de una semana variable y no variables (wk1 a wk76).

# NOTA: aunque este marco de datos es mucho más amplio que nuestros ejemplos anteriores, podemos usar la misma función y parámetros para hacerlo más largo:

billboard %>%
    pivot_longer(
        cols = contains("wk"),
        names_to = "week",
        values_to = "value",
        names_prefix = "^wk",
        names_transform = as.double
        )

## Las variables múltiples se almacenan en columnas ----

# NOTA: los casos de uso anteriores fueron bastante claros, ya que podríamos suponer que las columnas utilizadas para cols representan todos los valores de una sola variable. Sin embargo, este no es siempre el caso. Tomemos el conjunto de datos anscombe:

anscombe

anscombe %>%
    pivot_longer(
        cols = x1:y4,
        names_to = "axis",
        values_to = "value"
        ) # Una vez que hemos alargado este marco de datos, podemos ver de qué se trata. Puedo decirte esto: x representa valores en el eje x e y representa valores en el eje y. En otras palabras, los nombres de las columnas representan dos variables, x e y. Aplicar nuestra lógica pivot_longer a este ejemplo no funcionaría porque no podríamos capturar estas dos columnas.

# NOTA: para crear dos nuevas columnas de variables en names_to, necesitamos usar .value y el parámetro names_pattern:

anscombe_tidy <- anscombe %>%
    pivot_longer(
        cols = x1:y4,
        names_to = c(".value", "number"),
        names_pattern = "([xy])(\\d+)",
        values_to = "value"
        ) %>% # Para entender lo que hace .value, analicemos primero names_pattern. names_pattern toma una expresión regular. En el mundo de las expresiones regulares, cualquier cosa encerrada entre paréntesis se llama grupo. Los grupos nos permiten capturar partes de una cadena que pertenecen juntas. En este ejemplo: "([xy])(\\d+)". El primer grupo captura la letra x o y: ([xy]). El segundo grupo captura uno o más números: (\\d+). .value es un marcador de posición para estos dos elementos. Para cada elemento, se crea una nueva columna con el texto capturado en la expresión regular.
        glimpse()

# NOTA: ahora que tenemos datos ordenados, podemos visualizar la idea detrás del conjunto de datos de Anscombe:

anscombe_tidy %>%
    ggplot(aes(x = x, y = y)) +
    geom_point() +
    facet_wrap(vars(number)) # Los datos representan cuatro conjuntos de datos que tienen estadísticas descriptivas idénticas (p. ej., media, desviación estándar) pero que parecen ser visualmente diferentes entre sí.

## Varias variables se almacenan en una columna ----

# NOTA: veamos otro caso de uso y ejemplo. El conjunto de datos who proviene de la Organización Mundial de la Salud. Registra los casos confirmados de tuberculosis desglosados por país, año y grupo demográfico. Los grupos demográficos son sexo y edad. Los casos se dividen en cuatro tipos: rel = recaída, sn = frotis de pulmón negativo, sp = frotis de pulmón positivo, ep = extrapulmonar:

who # En este marco de datos, las variables subyacentes tipo, casos, edad y género están contenidas en los encabezados de las columnas. Tomemos la columna new_sp_m1524. sp representa el tipo que tiene un frotis de pulmón positivo. m representa hombre y 1524 representa el grupo de edad de 15 a 24 años. Otro problema con este marco de datos es que los nombres de las columnas no están bien formateados. En algunas columnas, new va seguido de un guión bajo new_sp_m3544, en otras no, newrel_m2534.

# NOTA: aquí puede ver cómo se puede ordenar este marco de datos con pivot_longer. Lo desglosaremos más a continuación:

who %>%
    pivot_longer(
        cols = new_sp_m014:newrel_f65,
        names_pattern = "new_?([a-z]{2,3})_([a-z])(\\d+)",
        names_to = c("type", "sex", "age"),
        values_to = "cases"
        ) %>%
    mutate(
        age = case_when(
            str_length(age) == 2 ~ age,
            str_length(age) == 3 ~ str_replace(age, "(^.)", "\\1-"),
            str_length(age) == 4 ~ str_replace(age, "(^.{2})", "\\1-"),
            TRUE ~ age)
        ) # Comencemos con pivot_longer. La principal diferencia con nuestro ejemplo anterior es que la expresión regular para name_pattern es más compleja. La expresión regular captura tres grupos. Cada grupo se convierte en una nueva columna: El primer grupo ([a-z]{2,3}) se convierte en una columna que representa el tipo de caso; El segundo grupo ([a-z]) se convierte en la columna de género; El tercer grupo (\\d+) se traduce a la columna edad. También solucionamos el problema con el guión bajo en la expresión regular haciéndolo opcional new_?. A continuación, tuvimos que limpiar la columna de edad usando mutate y case_when.

## Las variables se almacenan tanto en filas como en columnas ----

# NOTA: en nuestro último caso de uso, una variable subyacente se almacena tanto en columnas como en filas. Considere este marco de datos:

weather_data <- tribble(
    ~id, ~year, ~month, ~element, ~d1, ~d2, ~d3, ~d4, ~d5, ~d6,
    "MX17004", 2010, 1, "tmax", NA, NA, NA, NA, NA, NA,
    "MX17004", 2010, 1, "tmin", NA, NA, NA, NA, NA, NA,
    "MX17004", 2010, 2, "tmax", NA, 27.3, 24.1, NA, NA, NA,
    "MX17004", 2010, 2, "tmin", NA, 14.4, 14.4, NA, NA, NA,
    "MX17004", 2010, 3, "tmax", NA,NA, NA, NA, 32.1, NA,
    "MX17004", 2010, 3, "tmin", NA, NA, NA, NA, 14.2, NA,
    "MX17004", 2010, 4, "tmax", NA, NA, NA, NA, NA, NA,
    "MX17004", 2010, 4, "tmin", NA, NA, NA, NA, NA, NA,
    "MX17004", 2010, 5, "tmax", NA, NA, NA, NA, NA, NA,
    "MX17004", 2010, 5, "tmin", NA, NA, NA, NA, NA, NA
    ) %>% # Este marco de datos muestra datos de temperatura de una estación meteorológica en México. Las temperaturas mínimas y máximas se registraron diariamente. Las columnas d1 a d6 representan días, y las columnas año y mes representan el año y el mes, respectivamente.
    mutate(across(d1:d6, as.numeric))

# NOTA: lo sorprendente del marco de datos anterior es que la fecha de la variable subyacente se distribuye en filas y columnas. Dado que la variable de fecha debe estar en una columna, estos datos no están ordenados. Para resolver este problema, necesitamos hacer dos cosas. Primero, necesitamos alargar el marco de datos. En segundo lugar, necesitamos crear la columna de fecha. Así es como podríamos hacer esto:

weather_data_cleaned <- weather_data %>%
    pivot_longer(
        cols = d1:d6,
        names_to = "day",
        names_prefix = "d",
        values_to = "value",
        values_drop_na = TRUE
        ) %>%
    unite(
        col = date,
        year, month, day,
        sep = "-"
        ) %>%
    mutate(
        date = as.Date(date, format = "%Y-%m-%d")
        ) %>% 
    print()
