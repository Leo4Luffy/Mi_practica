# Tutorial "Cómo ejecutar muchos modelos con las nuevas funciones de agrupación de dplyr"

pacman::p_load('tidyverse', 'gapminder')

gapminder %>%
    glimpse() # El uso de muchos modelos puede ser una técnica poderosa para obtener información de sus datos. Un ejemplo clásico es el conjunto de datos de Gapminder. Suponga que desea averiguar si la esperanza de vida ha mostrado una tendencia lineal durante los últimos 50 años en países de todo el mundo.

# NOTA: podemos rastrear el desarrollo de la esperanza de vida en estos países utilizando un gráfico de líneas:

ggplot(data = gapminder, aes(x = year, y = lifeExp, group = country)) +
    geom_line(alpha = 0.3) # Lo que vemos es que, en promedio, la esperanza de vida ha aumentado desde 1952 hasta 2007. Algunos países han experimentado una disminución drástica de la esperanza de vida.

# NOTA: podemos obtener una mejor imagen si dividimos la trama por continente:

ggplot(data = gapminder, aes(x = year, y = lifeExp, group = country)) +
    geom_line(alpha = 0.3) +
    facet_wrap(vars(continent)) # Podemos ver que hay una disminución importante en África y dos disminuciones importantes en Asia.

## Construcción de un único modelo lineal ----

# NOTA: para averiguar qué tan bien ha seguido la esperanza de vida una tendencia lineal durante los últimos 50 años, construimos un modelo de regresión lineal con el año como variable independiente y la esperanza de vida como variable dependiente:

model <- lm(lifeExp ~ year, data = gapminder)
summary(model) # Vemos que nuestro coeficiente de regresión para la variable independiente año es positivo (año = 0,32590), lo que significa que la esperanza de vida ha aumentado con los años.

# NOTA: para realizar más análisis con los parámetros de nuestro modelo, podemos canalizar el modelo a la función ordenada del paquete broom:

model %>%
    broom::tidy()

# NOTA: del mismo modo, podemos obtener las estadísticas de prueba de nuestro modelo con glance:

model %>%
    broom::glance()

# NOTA: Lo anterior está muy bien, pero ¿cómo aplicaríamos el mismo modelo a cada país?:

## La técnica dividir (split) > aplicar (apply) > combinar (combine) ----

# NOTA: la solución al problema anterior de aplicar modelos a cada país es la técnica dividir > aplicar > combinar:

group_by_summarise_example <- gapminder %>%
    group_by(continent, year) %>%
    summarise(mean = mean(lifeExp, na.rm = TRUE)) %>%
    ungroup() %>%
    glimpse() # La combinación de group_by y summarise es un método de dividir > aplicar > combinar. Por ejemplo, podríamos dividir los datos por continente y año, calcular la media para cada grupo (aplicar) y combinar los resultados en un marco de datos.

group_by_summarise_example %>%
    ggplot(aes(x = year, y = mean)) +
    geom_line(aes(color = continent)) # Con los datos anteriores podemos gráficar la evolución de la esperanza de vida en los cinco continentes.

## Dividir > aplicar > combinar para ejecutar muchos modelos ----

# NOTA: ahora que tiene una idea de lo que hace dividir > aplicar > combinar, usémoslo para ejecutar muchos modelos. Y ejecutemos el mismo modelo lineal que acabamos de crear para cada país. A partir de los resultados de estos modelos, podemos hacernos una idea de dónde la esperanza de vida no sigue una tendencia lineal:

gapminder %>%
    split(.$country) %>%
    map_dfr(\(.x) lm(lifeExp ~ year, .x) %>% broom::glance()) # Sale error.
