# Tutorial "Cómo agrupar factores"

pacman::p_load('tidyverse')

# NOTA: un factor es una estructura de datos en R que le permite crear un conjunto de categorías. Llamamos a estas categorías niveles. Es bien sabido en la literatura psicológica que solo podemos almacenar un cierto número de cosas en nuestra memoria de trabajo. Por lo tanto, para ayudar a las personas a entender las categorías, no deberíamos mostrar demasiadas. Aquí es donde se muestra la fuerza de los factores de agrupamiento. Agrupar no es más que combinar niveles de factores en una categoría nueva y más grande. Digamos que queremos visualizar cuántos músicos llegaron al top 100 en 2000. Aquí hay un gráfico de barras que muestra cómo se ve esto:

billboard %>%
    ggplot(aes(y = artist)) +
    geom_bar()

# NOTA: la anterior visualización es completamente incomprensible. La función fct_lump viene a nuestro rescate:

billboard %>%
    mutate(artist = fct_lump(as_factor(artist), 10)) %>%
    filter(artist != 'Other') %>%
    ggplot(aes(y = artist)) +
    geom_bar()

# NOTA: proporcionamos fct_lump con un número. El número indica, bueno, ¿qué? 10 ciertamente no indica los niveles restantes que no fueron categorizados como “Otros”. Tampoco son 10 los niveles que juntamos. Resulta que fct_lump es una función bastante oscura porque elige diferentes métodos en función de sus argumentos. El equipo de tidyverse ya no recomienda el uso de esta función. Es por eso que se crearon cuatro funciones nuevas en 2020, que veremos a continuación:

# - fct_lump_min.
# - fct_lump_n.
# - fct_lump_prop.
# - fct_lump_lowfreq.

## La función fct_lump_min para agrupar niveles que ocurren no más de un mínimo de veces ----

billboard %>%
    mutate(artist = fct_lump_min(as_factor(artist), 3)) %>% # fct_lump_min resume todos los niveles que no aparecen más de un mínimo de veces. Aquí se quiso agrupar todos los niveles (o músicos) que llegaron al top 100 menos de tres veces en el 2000. Claramente, todos los demás músicos tenían al menos tres canciones que llegaron al Top 100.
    filter(artist != 'Other') %>%
    ggplot(aes(y = artist)) +
    geom_bar()

## La función fct_lump_n para agrupar n de los niveles que ocurren con mayor o menor frecuencia ----

billboard %>%
    mutate(artist = fct_lump_n(artist, n = -5)) %>% # Si especifica el argumento n con un número negativo, la función agrupará todos los niveles que ocurren con mayor frecuencia (exactamente lo contrario de lo que hace un número positivo). Por ejemplo, podríamos agrupar a los 5 músicos con más canciones en el Top 100.
    filter(artist != "Other") %>%
    ggplot(aes(y = artist)) +
    geom_bar()

billboard %>%
    mutate(artist = fct_lump_n(artist, n = 5)) %>% # Otro ejemplo si quisieramos agrupar todos los niveles excepto los 5 más comunes.
    filter(artist != 'Other') %>%
    ggplot(aes(y = artist)) +
    geom_bar()

# NOTA: Claramente, los anteriores no son cinco niveles. ¿Qué salió mal? Resulta que muchos niveles ocurren tres veces. Así que tenemos que decidir qué hacer con los niveles que ocurren la misma cantidad de veces. Los tres niveles más comunes son Jay-Z, Whitney Houston y The Dixie Chicks. Pero, ¿cuáles deberían ser los niveles 4 y 5 más frecuentes? Si no le da a la función ninguna información adicional, fct_lump_n le mostrará todos los niveles cuyo número cae por debajo del último nivel, que es claramente uno de los niveles más frecuentes. Puede cambiar este comportamiento con el argumento ties.method. El argumento por defecto es min, que acabamos de ver:

billboard %>%
    mutate(artist = fct_lump_n(artist, n = 5, ties.method = 'min')) %>%
    filter(artist != "Other") %>%
    ggplot(aes(y = artist)) +
    geom_bar()

# NOTA: las otras opciones son "average", "first", "last", "random" y "max":

billboard %>%
    mutate(artist = fct_lump_n(artist, n = 5, ties.method = 'max')) %>% # "max" elimina todos los niveles que no se pueden identificar de forma única.
    filter(artist != 'Other') %>%
    ggplot(aes(y = artist)) +
    geom_bar()

billboard %>%
    mutate(artist = fct_lump_n(artist, n = 5, ties.method = 'random')) %>% # "random" selecciona aleatoriamente los niveles que no se pueden identificar de forma única como los niveles más frecuentes.
    filter(artist != 'Other') %>%
    ggplot(aes(y = artist)) +
    geom_bar()
