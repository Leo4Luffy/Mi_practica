# Tutorial "Cómo mejorar el corte de filas"

pacman::p_load('tidyverse', 'lubridate')

# NOTA: tanto el corte como el filtrado le permiten eliminar o mantener filas en un marco de datos. Esencialmente, puede usar ambos para lograr el mismo resultado, pero sus enfoques difieren. Mientras que filter funciona con condiciones (por ejemplo, displ > 17), slice funciona con índices. Supongamos que queremos eliminar la primera, la segunda y la tercera fila del marco de datos econmics (574 filas) con slice:

economics %>%
    slice(1, 2, 3) # slice mantiene todas las filas para las que especifica índices positivos, en este caso 1, 2 y 3. Tenga en cuenta que en R la indexación comienza con 1 y no con 0 como en la mayoría de los otros lenguajes de programación. 


# NOTA: Para que quede más claro qué filas mantiene el segmento, agreguemos números de fila a nuestro marco de datos:

economics %>%
    rownames_to_column(var = 'row_number')

# NOTA: luego dividamos algunas filas arbitrarias:

economics %>%
    rownames_to_column(var = 'row_number') %>%
    slice(c(4, 8, 10)) # Puede ver que hemos conservado las líneas 4, 8 y 10, que se corresponden con nuestros índices proporcionados.

# NOTA: la función slice se explica rápidamente. Más interesantes, sin embargo, son las funciones auxiliares slice_head, slice_tail, slice_max, slice_min y slice_sample.

## Cómo cortar la parte superior e inferior de un marco de datos ----

# NOTA: imagine que ha realizado una encuesta y las dos primeras filas de su encuesta son datos de prueba:

survey_results <- tribble(
    ~id, ~name, ~pre, ~post,
    1, 'Test', 4, 4,
    2, 'Test', 6, 8,
    3, 'Millner', 2, 9,
    4, 'Josh', 4, 7,
    5, 'Bob', 3, 4
    )

# NOTA: la función sample_head permite cortar las n filas superiores de su marco de datos (en este caso los datos de prueba):

survey_results %>%
    slice_head(n = 2)

# NOTA: aunque lo anterior no es lo que queriamos, ya que se desea es cortar los datos de prueba. Una solución a este enigma es darle la vuelta al problema y cortar la cola del marco de datos en lugar de la cabeza:

survey_results %>%
    slice_tail(n = 3)

# NOTA: sin embargo, este enfoque es inestable. ¿Cómo sé que necesito cortar las últimas tres filas del marco de datos? ¿Qué sucede si el marco de datos aumenta a medida que aumenta el número de participantes? La mejor solución es escribir un código que le diga a la función que corte todas las filas excepto las dos primeras. Esto no es más que el número total de filas menos 2:

survey_results %>%
    slice_tail(n = nrow(.) - 2)

# NOTA: también podría haber resuelto el problema con la función filter, que incluso podría ser el método más sólido:

survey_results %>%
    filter(name != 'Test')

## Cómo cortar las filas con los valores más altos y más bajos en un columna dada ----

# NOTA: un caso de uso común es cortar las filas que tienen el valor más alto o más bajo dentro de una columna. Encontrar estas filas con filter sería tedioso. Para ver cuánto, vamos a intentarlo. Supongamos que queremos encontrar los meses en nuestro marco de datos cuando el desempleo fue más alto:

economics %>%
    filter(unemploy >= sort(.$unemploy, decreasing = TRUE)[10]) %>%
    arrange(desc(unemploy)) %>%
    select(date, unemploy) # El código dentro de la función filter es difícil de leer. Lo que hacemos aquí es extraer la columna de desempleo del marco de datos, ordenar los valores y obtener el décimo valor del vector ordenado.

# NOTA: una forma mucho más fácil de lograr el mismo resultado es usar slice_max:

economics %>%
    slice_max(
        order_by = unemploy,
        n = 10
        ) %>%
        select(date, unemploy) # Para el primer argumento order_by, especifica la columna para la que se deben tomar los valores más altos. Con n especifica cuántas de las filas con los valores más altos desea conservar.

# NOTA: del mismo modo, puede mantener las filas con los valores más bajos en una columna determinada:

economics %>%
    slice_min(order_by = unemploy, n = 3)

# NOTA: si está más interesado en el porcentaje de filas con el valor más alto, puede usar el argumento prop. Por ejemplo, dividamos el 10 % de los meses con la tasa de desempleo más alta:

economics %>%
    slice_max(order_by = unemploy, prop = 0.1)

## Cómo combinar las funciones slice y group_by ----

# NOTA: la función slice se vuelve especialmente poderosas cuando se combinan con group_by. Suponga que desea encontrar cada mes del año en que la tasa de desempleo fue más alta. El truco es que cualquier función llamada después de group_by solo se aplica a los subgrupos:

highest_unemploy_per_month <- economics %>%
    group_by(year = year(date)) %>%
    slice_max(
        order_by = unemploy,
        n = 1
        ) %>%
        ungroup() %>%
        glimpse()

# NOTA: estos datos podrían usarse, por ejemplo, para mostrar en qué meses la tasa de desempleo es más alta:

highest_unemploy_per_month %>%
    mutate(month = month(date) %>% as.factor) %>%
    count(month) %>%
    ggplot(aes(x = month, y = n)) +
    geom_col()

## Cómo crear bootstraps con slice_sample ----

# NOTA: otra función útil es slice_sample. Selecciona aleatoriamente filas de su marco de datos. Usted define cuántos deben seleccionarse. Por ejemplo, cortemos 20 filas de nuestro marco de datos:

economics %>%
    slice_sample(n = 20)

# NOTA: dado que anteriormente las líneas se seleccionan al azar, verá diferentes filas. Ahora, ¿qué sucede cuando muestreamos todas las filas de nuestro marco de datos?:

economics %>%
    slice_sample(prop = 1.0) # Nada cambia realmente. Obtendremos el mismo marco de datos. ¿Por qué? Porque slice_sample por defecto muestra sin reemplazo. Una vez que hemos seleccionado una fila, no podemos volver a seleccionarla. En consecuencia, no habrá filas duplicadas en nuestro marco de datos.

# NOTA: si establecemos el argumento de reemplazo en VERDADERO, realizaremos un muestreo con reemplazo:

set.seed(455)
sample_with_replacement <- economics %>%
    slice_sample(prop = 1.0, replace = TRUE) %>%
    glimpse()

sample_with_replacement %>%
    janitor::get_dupes() # Podemos encontrar las filas duplicadas con la función get_dupes del paquete janitor.

# NOTA: la funcionalidad anterior (muestreo con reemplazo) permite crear bootstraps a partir de nuestro marco de datos. Bootstrapping es una técnica en la que se extrae un conjunto de muestras del mismo tamaño a partir de una única muestra original. Por ejemplo, si tiene un vector c(1, 4, 5, 6), puede crear los siguientes bootstraps a partir de este vector: c(1, 4, 4, 6), c(1, 1, 1, 1) o c(5, 5, 1, 6). Algunos valores aparecen más de una vez porque el arranque permite extraer cada valor varias veces del conjunto de datos original. Una vez que tenga sus bootstraps, puede calcular métricas a partir de ellos. Por ejemplo, el valor medio de cada arranque. La lógica subyacente de esta técnica es que, dado que la muestra en sí es de una población, los bootstraps actúan como sustitutos de otras muestras de esa población.

# NOTA: ahora que hemos creado un programa de arranque a partir de nuestra muestra, podemos crear muchos. En el siguiente código, he usado map para crear 2000 bootstraps a partir de mi muestra original:

bootstraps <- map(1:2000, ~ slice_sample(economics, prop = 1.0, replace = TRUE))
bootstraps %>% head(n = 2)

# NOTA: map devuelve una lista de marcos de datos. Una vez que tenemos los bootstraps, podemos calcular cualquier métrica a partir de ellos. Por lo general, se calculan intervalos de confianza, desviaciones estándar, pero también medidas de centro como la media de bootstraps. Hagamos esto último:

means <- map_dbl(bootstraps, ~ mean(.$unemploy))

ggplot(NULL, aes(x = means)) +
    geom_histogram(fill = 'grey80', color = 'black') # Como puede ver, la distribución de la media se distribuye normalmente. La mayoría de los valores medios están alrededor de 7750, que está bastante cerca del valor medio de nuestra muestra: economics$unemploy %>% mean
