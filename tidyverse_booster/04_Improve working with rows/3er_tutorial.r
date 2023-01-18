# Tutorial "Cómo hacer cálculos por filas"

pacman::p_load('tidyverse')

# NOTA: suponga que este marco de datos representa los puntajes de las pruebas de cuatro estudiantes en tres momentos de medición: primero, segundo y tercero:

dframe <- tibble(
    name = c('Jakob', 'Eliud', 'Jamal', 'Emily'),
    first = c(1, 4, 7, 10),
    second = c(2, 5, 8,11),
    third = c(3, 6, 9, 12)
    )

# NOTA: calcular la media para cada persona a partir de estos tres puntos de medición debería ser sencillo:

dframe %>%
    mutate(mean_performance = mean(c(first, second, third))) # Aparentemente no. 6,5 ciertamente no es el valor promedio de una de estas filas. ¿Que está pasando aqui? Resulta que la media calcula el promedio de los 9 valores, no tres para cada fila. Similar a ésto: mean(c(c(1, 4, 7, 10), c(2, 5, 8,11), c(3, 6, 9, 12)))

# NOTA: lo anterior se debe a que la media no es una función vectorizada porque no realiza sus cálculos vector a vector. En su lugar, arroja cada vector en una caja y calcula el promedio general de todos sus valores. Este podría funcionar:

dframe %>%
    mutate(
        combined = paste(first, second, third),
        sum = first + second + third,
        mean = (first + second + third) / 3
        )

# NOTA: Entonces, el problema ocurre con funciones que no están vectorizadas (por ejemplo, media) y con funciones base R que calculan estadísticas de resumen. Hay varias soluciones a este problema. El primero es por filas (rowwise).

## Introducción a rowwise ----

# NOTA: esencialmente, la función asegura que las operaciones se realicen fila por fila. Funciona de forma similar a group_by. No cambia el aspecto del marco de datos, sino cómo se realizan los cálculos con el marco de datos:

dframe %>%
    rowwise() # Como puedes ver, nada cambia. La salida solo le dice que se realizarán los cálculos fila por fila.

# NOTA: si calculamos la media del rendimiento del individuo, obtenemos los resultados correctos:

dframe %>%
    rowwise() %>%
    mutate(mean_performance = mean(c(first, second, third)))

dframe %>%
    group_by(name) %>%
    mutate(mean = mean(c(first, second, third))) %>%
    ungroup() # En realidad, rowwise es un caso especial de group_by.

# NOTA: la misma lógica se aplica a todas las demás funciones base de R que calculan estadísticas de resumen:

dframe %>%
    rowwise() %>%
    mutate(
        mean_performance = mean(c(first, second, third)),
        sum_performance = sum(c(first, second, third)),
        min_performance = min(c(first, second, third)),
        max_performance = max(c(first, second, third)),
        median_performance = median(c(first, second, third))
        )

## Cómo usar las funciones tidyselect con rowwise ----

dframe %>%
    rowwise() %>%
    mutate(mean_performance = mean(where(is.numeric))) # Se puede ver aquí que no es posible agregar una función tidyselect dentro de la media o cualquiera de las otras funciones.

# NOTA: en los casos anteriores, se puede usar c_across. Este fue desarrollado especialmente para filas y puede considerarse como un contenedor de c().

dframe %>%
    rowwise() %>%
    mutate(mean_performance = mean(c_across(where(is.numeric))))

billboard %>%
    rowwise() %>%
    transmute(
        artist,
        track,
        sum = sum(c_across(contains('wk')), na.rm = TRUE)
        ) # Esto es especialmente importante si necesita realizar cálculos en muchas columnas, como en este marco de datos.

# NOTA: es importante mencionar que similar a group_by, rowwise también se necesita desagrupar con ungroup().

## Cálculo de proporciones con rowwise ----

sums_per_row <- dframe %>%
    rowwise() %>%
    mutate(sum_per_row = sum(first, second, third)) %>%
    ungroup() # Para calcular proporciones, primero debes calcular la suma de todos los valores.

sums_per_row %>%
    transmute(
        name,
        across(
            .cols = where(is.numeric),
            .fns = ~ . / sum_per_row
            )
        ) # Con la columna sum_per_row, podemos usar y convertir todas las columnas numéricas en proporciones.
