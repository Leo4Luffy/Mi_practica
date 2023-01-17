# Tutorial "Cómo contar valores con count, add_count y add_tally"

pacman::p_load('tidyverse')

starwars %>%
    count(decade = 10 * (birth_year %/% 10), name = 'characters_per_decade') %>% # Aquí, se quiso saber el número de personajes de starwars que nacieron en cada decada. Para ello, se uso la división de enteros que en R se puede hacer con el operador %/%, y esta operación se combino con la función count. Todo esto creando una nueva variable dentro de la función count.
    glimpse()

## Cómo calcular la suma de una variable basada en grupos sin usar group_by ----

economics %>%
    mutate(year = format(date, '%Y')) %>%
    group_by(year) %>%
    summarise(sum_unemploy = sum(unemploy, na.rm = TRUE)) # Aquí, la suma de personas desempleadas en los EE. UU. por año usando la función group_by y summarise.

economics %>%
    count(year = format(date, '%Y'), wt = unemploy, name = 'sum_unemploy') # Para lograr el mismo resultado anterior con count, necesita conocer el argumento wt. wt significa recuentos ponderados. Mientras que count calcula la frecuencia de valores dentro de un grupo sin especificar el argumento wt (n = n()), wt calcula la suma de una variable continua para ciertos grupos (n = sum(<VARIABLE>)).

# NOTA: Esta técnica tiene sus ventajas y desventajas. En el lado positivo, solo necesitamos tres líneas de código en lugar de seis. En el lado negativo, el código es menos explícito y, sin conocer el funcionamiento interno de count, es difícil decir que la función está calculando sumas. Sin embargo, podría ser una nueva opción en tu caja de herramientas para calcular sumas.

## Cómo agregar cuentas como una variable a su marco de datos ----

# NOTA: En los ejemplos anteriores, vio que el recuento crea un nuevo marco de datos con la variable de agrupación y la variable de frecuencia o suma. Esto no siempre es lo que quieres. A veces desea agregar recuentos a su marco de datos existente.

mpg %>%
    add_count(manufacturer, name = 'number_of_cars_by_manufacturer') %>% # Aquí, se quiso contar cuántos automóviles hay por fabricante y agregar esos números al marco de datos de mpg usando add_count.
    select(manufacturer, model, number_of_cars_by_manufacturer) %>%
    glimpse()

## Cómo agregar una nueva variable a su marco de datos que contiene la suma de una variable específica ----

mpg %>%
    group_by(model) %>%
    add_tally(wt = displ, name = 'sum_display_per_model') %>% # add_tally() hace algo similar a add_count(). La única diferencia es que add_tally calcula la suma de una variable dada en lugar de un conteo. Por ejemplo, podríamos agregar una nueva variable a mpg que muestre la suma de las variables por modelo.
    select(manufacturer, model, sum_display_per_model) %>%
    glimpse()
