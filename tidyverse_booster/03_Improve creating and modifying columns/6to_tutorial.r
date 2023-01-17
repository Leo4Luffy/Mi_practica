# Tutorial "Cómo aplicar una función a través de muchos columnas"

pacman::p_load('tidyverse')

# NOTA: se hablara sobre la función across. Algunas cosas importantes sobre esta función:

# - La función across solo funciona dentro de los verbos dplyr (por ejemplo, mutate) 
# - La función tiene tres argumentos importantes: .cols representa la columna a la que se aplica una función. Puede utilizar las funciones tidyselect aquí; .fns representa las funciones que se aplicarán a estas columnas; .names se utiliza siempre que desee cambiar los nombres de las columnas seleccionadas. 
# - El argumento .fns toma tres valores diferentes: (1) Una función simple (por ejemplo, mean), (2) Una función lambda estilo purrr (por ejemplo, ~ mean(.x, na.rm = TRUE)), (3) Una lista de funciones (por ejemplo, list(mean = mean, sd = sd)). La lista también se puede combinar con funciones lambda (p. ej. list(mean = mean(.x, na.rm = TRUE), sd = sd(.x, na.rm = TRUE))).

## Cómo calcular estadísticas de resumen en muchas columnas con across y summarise ----

# NOTA: aquí hay un ejemplo típico de como las personas calculan estadísticas de resumen con dplyr:

mpg %>%
    group_by(manufacturer) %>%
    summarise(
        mean_displ = mean(displ, na.rm = TRUE),
        mean_cty = mean(cty , na.rm = TRUE)
        ) # Este enfoque funciona, pero no es escalable. Imagina que tuvieras que calcular la media y la desviación estándar de docenas de columnas.

# NOTA: en su lugar, puede utilizar la función across para obtener el mismo resultado:

mpg %>%
    group_by(manufacturer) %>%
    summarise(
        across(
            .cols = c('displ', 'cty'),
            .fns = ~ mean(.x, na.rm = TRUE),
            .names = 'mean_{.col}'
        )
    ) # Con el argumento .cols (.cols = c('displ', 'cty')) le dijimos que queríamos aplicar una función a estas dos columnas. Con el argumento .fns (.fns = ~ mean(.x, na.rm = TRUE)) decimos que queremos calcular la media de las dos columnas. También queremos eliminar NA de cada columna. Usando el argumento .names (.names = 'mean_{.col}'), dijimos que queríamos que las columnas resumidas tuvieran la siguiente estructura: Comience con la cadena mean_ y pegue el nombre de la columna a esta cadena ({ .col}).

mpg %>%
    group_by(manufacturer) %>%
    summarise(
        across(
            .cols = c('displ', 'cty'),
            .fns = mean,
            .names = 'mean_{.col}',
            na.rm = TRUE # la función across también puede tomar argumentos adicionales. Por ejemplo, el argumento na.rm de la función mean. Sin embargo, dos razones para no hacer esto: Primero, causa problemas en el momento de la evaluación. En otras palabras, puede dar lugar a errores. En segundo lugar, desvincula los argumentos de las funciones a las que se aplican. Lo mejor que puedes hacer es no hacer esto.
        )
    )

mpg %>%
    group_by(manufacturer) %>%
    summarise(
        across(
            .cols = c('displ', 'cty'),
            .fns = list(mean = mean, sd = sd),
            .names = '{.fn}_{.col}'
        )
    ) # Aquí se quiso también calcular la desviación estándar de cada columna. Para ello, primero creamos una lista con dos funciones (list(mean = mean, sd = sd)). En segundo lugar, cambiamos la cadena del argumento .names. En lugar de mean_{.col} usamos la cadena {.fn}_{.col}. {.fn} y {.col} son símbolos especiales y representan la función y la columna. Dado que tenemos más de una función, debemos tener la flexibilidad de crear nombres de columna que combinen el nombre de la columna con el nombre de la función aplicada a la columna.

# NOTA: una vez que tengamos esta estructura, podemos agregar tantas columnas y funciones como necesitemos:

mpg %>%
    group_by(manufacturer) %>%
    summarise(
        across(
            .cols = where(is.numeric),
            .fns = list(mean = mean, sd = sd, median = median),
            .names = '{.fn}_{.col}'
        )
    ) %>%
    glimpse()

## Cómo calcular el número de valores distintos en muchas columnas con across y summarise ----

mpg %>%
    summarise(
        across(
            .cols = everything(),
            .fns = n_distinct
        )
    ) # Puede preguntarse: "¿Qué estadísticas de resumen puedo calcular a partir de un vector?" Una de esas estadísticas es el número de valores distintos en un vector: ¿Cuántas personas tengo? ¿De cuántos estados provienen estas personas? ¿Cuántos fabricantes hay en los datos? Una mirada a los resultados muestra que los datos incluyen 15 fabricantes de automóviles y 38 modelos de automóviles diferentes.

## Cómo cambiar el tipo de variable en muchas columnas con across y mutate ----

# NOTA: suponga que algunas de sus columnas de caracteres deben transferirse a un factor, esto se haria así:

mpg %>%
    mutate(
        across(
            .cols = where(is.character),
            .fns = as_factor
        )
    ) %>%
    select(where(is.factor) | where(is.character)) %>%
    glimpse()

# NOTA: con mutate, normalmente especifica la nueva columna que se creará o sobrescribirá. Con across no tienes que hacer eso. Sin especificar el argumento .names, los nombres de sus columnas siguen siendo los mismos, solo aplica la(s) función(es) a esas columnas. En este ejemplo, aplicamos la función as_factor a cada columna de caracteres. También podríamos haber cambiado los nombres de las columnas y creado nuevas columnas en su lugar:

mpg %>%
    mutate(
        across(
            .cols = where(is.character),
            .fns = as_factor,
            .names = "{.col}_as_factor"
        )
    ) %>%
    select(where(is.factor) | where(is.character)) %>%
    glimpse()

## Cómo normalizar muchas columnas con across y mutate ----

# NOTA: los estadísticos y científicos a menudo necesitan normalizar sus datos. Suponga que desea normalizar sus datos para que cada columna tenga una media de 0 y una desviación estándar de 1:

mpg %>%
    transmute(
        across(
            .cols = where(is.numeric),
            .fns = scale,
        )
    ) %>%
    glimpse() # Dos cosas: primero, usé la función transmutar para mantener solo las columnas a las que se aplicó la función de escala. Segundo, el resultado no es un conjunto de vectores, sino matrices.

# NOTA: El valor antes de la coma indica las filas que queremos seleccionar, el valor después de la coma indica las columnas. Para solucionar nuestro problema, necesitamos agregar esta sintaxis a nuestra función de escala:

mpg %>%
    transmute(
        across(
            .cols = where(is.numeric),
            .fns = ~ scale(.)[,1],
        )
    ) %>%
    glimpse()

## Cómo imputar valores en muchas columnas con across y mutate ----

# NOTA: cuando imputamos valores faltantes, los reemplazamos con valores sustituidos. Este método de imputación podía funcionar con across y mutate. Supongamos que este es su marco de datos:

dframe <- tibble(
    group = c('a', 'a', 'a', 'b', 'b', 'b'),
    x = c(3, 5, 4, NA, 4, 8),
    y = c(2, NA, 3, 1, 9, 7)
    )

# NOTA: se observa en el marco de datos anterior que tiene dos columnas y en ambas columnas tiene un valor faltante. Desea reemplazar cada valor faltante con el valor medio de la columna respectiva:

dframe %>%
    mutate(
        across(
            .cols = c(x, y), # O con everything()
            .fns = ~ ifelse(test = is.na(.),
                            yes = mean(., na.rm = TRUE),
                            no = .)
        )
    ) # Para cada valor en cada columna, probamos si el valor es NA. Si lo es, reemplazamos este valor con el valor de la columna, si es un número real, lo mantenemos.

dframe %>%
    mutate(
        across(
            .cols = c(x, y), # O everything()
            .fns = ~ case_when(
                            is.na(.) ~ mean(., na.rm = TRUE),
                            TRUE ~ .
                            )
                )
            ) # También podríamos haber usado la función if vectorizada case_when.

## Cómo reemplazar caracteres en muchas columnas con across y mutate ----

# NOTA: suponga que tiene el mismo error tipográfico en muchas columnas:

typo_dframe <- tribble(
    ~pre_test, ~post_test,
    'goud', 'good',
    'medium', 'good',
    'metium', 'metium',
    'bad', 'goud'
    ) %>% # "goud" deberia ser "good" y "metium" deberia ser "medium".
    glimpse()

# NOTA: podemos combinar mutate con across para corregir estos errores tipográficos en ambas columnas:

typo_corrected <- typo_dframe %>%
    mutate(
        across(
            .cols = everything(),
            .fns = ~ case_when(
                str_detect(., 'goud') ~ str_replace(., 'goud', 'good'),
                str_detect(., 'metium') ~ str_replace(., 'metium', 'medium'),
                TRUE ~ .
                )
            )
        ) %>%
        glimpse()
