# Tutorial "Cómo hacer uso de las funciones internas de Curly Curly"

pacman::p_load('tidyverse')

# NOTA: en este tutorial hablaremos sobre el operador curly curly {{}} del paquete rlang. Curly curly le permite hacer referencia a los nombres de las columnas dentro de las funciones tidyverse. Básicamente, curly curly le permite tratar los nombres de las columnas como si estuvieran definidos en el espacio de trabajo. También es más fácil escribir código porque tienes que escribir menos.

## ¿Qué es curly curly y el paquete rlang? ----

# NOTA: a medida que profundicen en el tidyverse, tarde o temprano escucharán sobre la evaluación ordenada, el enmascaramiento de datos y el operador curly curly {{}}. Todos los conceptos tienen su base en el paquete rlang del paquete tidyverse. rlang es una colección de marcos y herramientas que te ayudan a programar con R. La mayoría de los usuarios de R que no escriben paquetes no necesitarán invertir mucho tiempo en el paquete rlang. A veces, sin embargo, se produce un error que tiene sus raíces en la lógica del paquete rlang. Aquí está el problema: suponga que ha escrito una función y desea pasar una variable como argumento al cuerpo de la función. La función debe filtrar un marco de datos para una variable que sea mayor que un valor especificado. Si ejecuta esta función, obtendrá el siguiente error:

filter_larger_than <- function(data, variable, value) {
    data %>%
    filter(variable > value)
    }

filter_larger_than(data = mpg, variable = displ, value = 4)

# NOTA: el problema anterior es que olvidó encerrar la variable en el operador curly curly. Pero antes de que aprendamos la mecánica para resolver el problema, es útil aprender un poco de terminología. Comencemos a continuación con una evaluación ordenada.

## ¿Qué es una evaluación ordenada? ----

# NOTA: es posible que haya notado que para casi todas las funciones de tidyverse, simplemente puede hacer referencia a los nombres de las columnas sin especificar los marcos de datos de los que provienen. En este ejemplo, podemos referirnos directamente a displ sin especificar su marco de datos (mpg$displ):

mpg %>%
    filter(displ > 6)

# NOTA: la técnica que hace lo anterior posible se llama evaluación ordenada. En otras palabras, “permite manipular columnas de marcos de datos como si estuvieran definidas en el espacio de trabajo” (https://www.tidyverse.org/blog/2019/06/rlang-0-4-0/).

# NOTA: el espacio de trabajo también se denomina entorno global. Puede pensar en un entorno como una lista con nombre (por ejemplo, x, y, mi_función) o una bolsa de nombres sin ordenar. Para ver los nombres en su entorno, puede usar ls:

ls(all.names = TRUE)

# NOTA: el entorno en el que normalmente trabaja se denomina entorno global o espacio de trabajo. Podemos verificar si el entorno es el entorno global ejecutando esta función:

environment()

# NOTA: se puede acceder a todos los objetos en el área de trabajo a través de sus scripts R y la consola. Si tuviéramos que crear un nuevo marco de datos llamado my_tibble, veríamos que las columnas del marco de datos no son parte del entorno, pero el marco de datos si lo es:

my_tibble <- tibble(
    id = 1, 2, 3,
    column_one = c(1, 3, 4)
    )
ls()

# NOTA: con una evaluación ordenada, R actúa como si las columnas de los marcos de datos fueran parte del entorno. En otras palabras, son accesibles a través de las funciones del tidyverse. Una mirada más cercana al entorno nos muestra que las columnas del marco de datos my_tibble no pertenecen a él. Sin embargo, a través de una evaluación ordenada podemos acceder a ellos en funciones como filter y select.

# NOTA: hay dos tipos de evaluaciones ordenadas: enmascaramiento de datos y selección ordenada. El enmascaramiento de datos hace posible el uso de columnas como si fueran variables en el entorno. La selección ordenada hace posible hacer referencia a columnas dentro de argumentos de selección ordenada (como starts_with).

## ¿Qué es el enmascaramiento de datos? ----

# NOTA: el enmascaramiento de datos le permite usar nombres de columnas directamente en arrange, count, filter y muchas otras funciones del tidyverse. El término en sí te dice lo que hace: enmascara los datos. El beneficio del enmascaramiento de datos es que necesita escribir menos. Sin el enmascaramiento de datos, deberá referirse a los nombres de las columnas con el nombre del marco de datos y $: por ejemplo mpg$displ. Como resultado, el código será más difícil de leer. Aquí hay un ejemplo con el R base:

mpg[mpg$manufacturer == "audi" & mpg$displ > 3, ]

# NOTA: Dentro del tidyverse puedes hacer que las columnas enmascaradas sean explícitas usando el pronombre .data:

mpg %>%
    filter(.data$displ > 6)

## ¿Qué es curly curly {{}}? ----

# NOTA: curly curly es un nuevo operador que se introdujo en rlang 0.4.0. En resumen, curly curly hace que el enmascaramiento de datos funcione dentro de las funciones.

# NOTA: es posible que haya intentado crear una función que use funciones del tidyverse en el cuerpo de la función. Suponga que desea escribir una función que filtre un marco de datos en función de un valor mínimo de una columna en particular. Como hemos visto al comienzo de este tutorial, este enfoque no funciona:

filter_larger_than <- function(data, variable, value) {
    data %>%
    filter(variable > value)
    }

filter_larger_than(data = mpg, variable = displ, value = 4)

# NOTA: en su lugar, debe encerrar los nombres de las columnas con el operador curly curly:

filter_larger_than <- function(data, variable, value) {
    data %>%
    filter({{variable}} > value)
    }

filter_larger_than(data = mpg, variable = displ, value = 4)

# NOTA: la evaluación ordenada o el enmascaramiento de datos también funcionan para visualizaciones de datos escritas en ggplot2. Si desea crear una función que devuelva un objeto ggplot, puede hacer referencia a una columna especificada en los argumentos encerrándola con el operador curly curly. La siguiente función crea, por ejemplo, un histograma para un marco de datos arbitrario y una columna del marco de datos:

custom_histogram <- function(data, variable) {
    data %>%
    ggplot(aes(x = {{variable}})) +
    geom_histogram(fill = "grey90", color = "grey20")
    }

custom_histogram(data = mpg, variable = displ)

## Cómo pasar múltiples argumentos a una función con el argumento punto-punto-punto (...) ----

# NOTA: una pregunta razonable para hacer en este punto sería si los argumentos múltiples pasados a una función a través de la sintaxis de punto-punto-punto también deben estar encerrados por un operador curly curly. La respuesta es no. Exploremos a continuación algunos ejemplos.

# NOTA: para aquellos que no están familiarizados con los argumentos punto-punto-punto, veamos un ejemplo simple. La función custom_select toma dos argumentos: un marco de datos y un número arbitrario de argumentos desconocidos. En este caso ... es un marcador de posición para una lista de nombres de columna:

custom_select <- function(data, ...) {
    data %>%
    select(...)
    }

custom_select(data = mpg, displ, manufacturer)

# NOTA: puede suceder que tenga que encerrar una columna con el operador curly curly y usar los argumentos ..., como en este ejemplo. La función get_summary_statistics agrupa el marco de datos por una columna específica y luego calcula la media y la desviación estándar para cualquier número de columnas en ese marco de datos. Vea a continuación cómo no usamos un operador curly curly para los argumentos ...:

get_summary_statistics <- function(data, column, ...) {
    data %>%
    group_by({{column}}) %>%
    summarise(
        across(
            .cols = c(...),
            .fns = list(
                mean = ~ mean(., na.rm = TRUE),
                sd = ~ sd(., na.rm = TRUE)
                )
            )
        )
    }

get_summary_statistics(data = mpg, column = manufacturer, displ, cyl)

# NOTA: a continuación hay otro ejemplo usando slice_max. Nuevamente, curly curly solo se usa para la columna de columna específica que está enmascarada:

slice_max_by <- function(data, ..., column, n) {
    data %>%
    group_by(...) %>%
    slice_max({{column}}, n = n) %>%
    ungroup()
    }

slice_max_by(data = diamonds, cut, color, column = price, n = 1)

# NOTA: ejemplos anteriores ... era un marcador de posición para los nombres de las columnas. Del mismo modo, puede especificar argumentos completos para ...:

grouped_filter <- function(data, grouping_column, ...) {
    data %>%
    group_by({{grouping_column}}) %>%
    filter(...) %>%
    ungroup()
    }

grouped_filter(data = mpg, grouping_column = manufacturer, displ > 5, year == 2008)

# NOTA: esto concluye nuestro tutorial sobre el operador curly curly. El concepto no es difícil de comprender, pero es esencial si desea escribir funciones personalizadas y pasar columnas al cuerpo de la función.
