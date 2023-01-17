# Tutorial "Cómo usar extract para crear varias columnas a partir de una columna"

pacman::p_load('tidyverse')

# NOTA: extract es la versión más potente de separate:

tibble(
    variable = c('a-b', 'a-d', 'b-c', 'd-e')
    ) %>%
    separate(
        col = variable,
        into = c('a', 'b'),
        sep = '-',
        remove = FALSE
        ) #  La función separate permite dividir una variable de carácter en múltiples variables, como en este ejemplo.

# NOTA: Sin embargo el enfoque anterior alcanza sus límites con bastante rapidez. Sobre todo si no tenemos un separador claro para distinguir las columnas que queremos crear. Para estos casos de uso tenemos la función extract. La diferencia clave entre separate y extract es que extract funciona con grupos dentro de sus expresiones regulares. Por ahora, digamos que un grupo se indica mediante dos paréntesis en expresiones regulares: (). Definimos grupos en extract para decirle a la función qué partes de una columna deben representar una nueva columna.

## Cómo extraer una columna de caracteres simple ----

tibble(
    variable = c('a-b', 'a-d', 'b-c', 'd-e')
    ) %>%
    extract(
        col = variable,
        into = c('a', 'b'),
        regex = '([a-z])-([a-z])',
        remove = FALSE
        ) # Este es el ejemplo más simple, una columna separada por un guión. extract toma algunos argumentos: col especifica la columna de caracteres que se dividirá en varias columnas, into especifica el nombre de las columnas que se crearán, regex define la expresión regular en la que capturamos los grupos que representarán las nuevas columnas y remove le dice a la función si la columna original debe ser eliminada (por defecto TRUE).

tibble(
    variable = c('x1', 'x2', 'y1', 'y2')
    ) %>%
    extract(
        col = variable,
        into = c('letter', 'number'),
        regex = '([xy])(\\d)',
        remove = FALSE
        ) # Este es otro ejemplo, una letra y un número. En este marco de datos, queremos extraer dos columnas de una columna. El primero debe ser la primera letra, el segundo el número. De hecho, en este ejemplo ya ni siquiera tenemos un separador. Nuevamente, hemos definido dos grupos para las dos columnas. El primer grupo captura las letras x o y marcadas con corchetes (([xy])), el segundo grupo captura un solo número ((\\d)).

## Cómo extraer una columna de caracteres más complicada ----

tibble(
    variable = c('x -> 1', 'y -> 2', 'p-> 34')
    ) %>% # Este es un ejemplo del concepto de paréntesis que no agrupan, es decir, grupos no se convierten en una nueva columna, pero que permiten extraer columnas que tienen algunas inconsistencias.
    extract(
        col = variable,
        into = c('letter', 'number'),
        remove = FALSE,
        regex = '([a-z])(?: ?-> ?)(\\d+)?'
        ) # Aquí, queremos crear dos columnas separadas por un ->.

# NOTA: la parte más importante del ejemplo anterior es esta: (?: ?-> ?). Esto se llama paréntesis de no agrupación. Un paréntesis de no agrupación se define por un grupo que comienza con un signo de interrogación y dos puntos: (?:). La ventaja de este método es que podemos resolver problemas de separación de columnas causados por variables desordenadas o inconsistentes. A continuación otro ejemplo de esto:

tibble(
    variable = c('x ->-> 1', 'y -> 2', 'p-> 34', 'f 4')
    ) %>% # En este ejemplo de separadores inconsistentes, queremos extraer columnas de una variable que tiene una flecha como separador (->). Sin embargo, a veces podemos encontrar dos o más flechas en la cadena de caracteres o ninguna flecha.
    extract(
        col = variable,
        into = c('letter', 'number'),
        remove = FALSE,
        regex = '([a-z]) ?(?:->){0,} ?(\\d+)?'
        ) # Nuestro paréntesis de no agrupación busca cualquier número de flechas entre nuestras dos nuevas variables: (?:->){0,}. El 0 indica que también podemos encontrar una cadena de caracteres que no contenga una flecha. Por lo tanto, podemos extraer el último valor al que le falta la flecha: f 4. La coma {0,} indica que la flecha se puede repetir infinitamente.

tibble(
    variable = c('x ->aslkdfj 1', 'y-> 2', 'p 34', '8')
    ) %>% # Este es un ejemplo en encontrar algunos errores tipográficos después de la flecha ->aslkdfj. Este problema también se puede resolver con paréntesis de no agrupación
    extract(
        col = variable,
        into = c('letter', 'number'),
        remove = FALSE,
        regex = '([a-z])? ?(?:->\\w*)? ?(\\d+)'
        ) # Aquí se han cambiado algunas cosas. Primero, agregué la expresión regular \\w* al paréntesis de no agrupación. Esta expresión regular busca cualquier número de letras. El asterisco * indica que esperamos de cero a un número infinito de letras. También puede ver que es posible que ni siquiera encontremos una letra para la primera columna recién creada. Aquí el signo de interrogación ([a-z])? indica que la primera letra es opcional.

# NOTA: los paréntesis que no agrupan se pueden usar para trabajar con columnas desordenadas y no se convierten en columnas nuevas.
