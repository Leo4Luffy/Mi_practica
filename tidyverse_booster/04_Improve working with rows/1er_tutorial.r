# Tutorial "Cómo filtrar filas en función de varias columnas"

pacman::p_load('tidyverse')

# NOTA: suponga que desea filtrar todas las filas de su marco de datos que contienen un valor faltante. Si solo tiene unas pocas columnas, puede resolver este problema de la siguiente manera:

df <- tibble(
    a = c(1, 2, 3),
    b = c(NA, 4, 8),
    c = c(1, 4, 1)
    )

df %>%
    filter(!is.na(a) & !is.na(b) & !is.na(c)) # La función filter básicamente dice lo siguiente: Encuentre las filas donde ni a, ni b, ni c son valores faltantes. Para lograr esto, repetimos el código !is.na tres veces.

# Nota: la forma anterior es propenso a errores en especial si se tienen docenas de filas. Para escalar la solución a este problema, necesitamos una forma de verificar automáticamente una condición en varias columnas. Las funciones que pueden ayudar con esto son if_any y if_all.

## Cómo filtrar filas en función de una condición en varias columnas ----

# NOTA: suponga que está trabajando con el marco de datos billboard, que contiene las clasificaciones de las canciones durante un período de 76 semanas. Las columnas "wk1" a "wk76" contienen las clasificaciones de cada semana. Supongamos además que desea filtrar las canciones que llegaron al número 1 durante al menos una semana. Así es como harías esto con if_any:

billboard %>%
    filter(
        if_any(
            .cols = contains('wk'),
            .fns = ~ . == 1
            )
        )

# NOTA: Intercambiemos if_any con if_all y veamos qué sucede:

billboard %>%
    filter(
        if_all(
            .cols = contains("wk"),
            .fns = ~ . == 1
            )
        ) # Obtenemos un marco de datos vacío. Eso es porque no hay ninguna canción que se haya mantenido en el número 1 durante más de 76 semanas. De hecho, la mayoría de las canciones salieron del Top 100 poco después de su lanzamiento, lo que generó NA en nuestro marco de datos.

# NOTA: Aquí hay una forma más inteligente de usar if_all. Supongamos que desea filtrar aquellas canciones que se mantuvieron en el Top 50 durante las primeras cinco semanas:

billboard %>%
    filter(
        if_all(
            .cols = matches('wk[1-5]$'),
            .fns = ~ . <= 50
            )
        ) # Primero usamos la función matches para verificar la condición en las columnas "wk1" a "wk5". Luego definimos la condición en sí, que busca valores menores o similares a 50.

## Cómo filtrar filas que contienen valores faltantes ----

# NOTA: otro caso de uso muy útil es el filtrado de filas en función de los valores faltantes en varias columnas. El siguiente marco de datos contiene tres valores faltantes:

df <- tibble(
    item_name = c('a', 'a', 'b', 'b'),
    group = c(1, NA, 1, 2),
    value1 = c(1, NA, 3, 4),
    value2 = c(4, 5, NA, 7)
    ) %>%
    glimpse()

# NOTA: mantengamos todas las filas cuyas columnas numéricas no contengan valores faltantes:

df %>%
    filter(
        if_all(
            .cols = where(is.numeric),
            .fns = ~ !is.na(.)
            )
        ) # Esto nos deja con dos filas.

## Cómo crear nuevas condiciones basadas en columnas en varias columnas ----

# NOTA: el último ejemplo de if_any y if_all funciona con mutar en lugar de filtrar. Resulta que podemos combinar case_when con if_any / if_all para crear una nueva columna basada en múltiples condiciones de expansión de columnas. Supongamos que queremos crear una nueva columna que muestre si una canción fue #1 en las 76 semanas:

billboard %>%
    mutate(
        top_song = case_when(
            if_any(
                .cols = contains('wk'),
                .fns = ~ . == 1
                ) ~ 'top song',
                TRUE ~ 'no top song'
                )
            ) %>%
            select(artist, track, top_song)
