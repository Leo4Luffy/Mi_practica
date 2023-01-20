# Tutorial "Cómo expandir marcos de datos y crear combinaciones completas de valores"

pacman::p_load('tidyverse')

# NOTA: es difícil distinguir las funciones completar (complete), expandir (expand), anidar (nesting) y cruzar (crossing). En cierto sentido, hacen cosas similares: encuentran combinaciones de valores en vectores o columnas. Tomemos un tiempo para analizar estas funciones.

# NOTA: para este tutorial, utilizaremos un conjunto de datos inventados de eventos en ejecución. Supongamos que el siguiente marco de datos muestra las carreras a pie que ha completado un corredor desde 2010. Los minutos muestran el tiempo que le tomó a esta persona completar las carreras. Llamémosla a la corredora Ana:

running_races_anna <- tribble(
    ~year, ~race, ~minutes,
    2010, "half marathon", 110,
    2011, "marathon", 230,
    2013, "half marathon", 105,
    2016, "10km", 50,
    2018, "10km", 45,
    2018, "half marathon", 100,
    2022, "marathon", 210
    ) # Puedes ver que faltan algunos años. Anna no corrió una carrera en 2012. Tampoco corrió una media maratón en 2016. En los próximos capítulos, intentaremos completar este marco de datos con las cuatro funciones complete, expand, nesting y crossing.

## La función complete ----

# NOTA: supongamos que Anna solo ha corrido 10K, medios maratones y maratones en los últimos años. Supongamos además que ella podría haber participado en todas las carreras cada año. ¿En cuántas carreras podría haber participado entonces?

# NOTA: un primer enfoque podría ser convertir las combinaciones implícitas en combinaciones explícitas utilizando complete. Básicamente, esto no significa nada más que crear nuevas filas que representen las carreras en las que no participó. Para estas ejecuciones, complete establece los valores de la columna de minutos en NA:

running_races_anna %>%
    complete(year, race) # Si miras este resultado, notarás que complete hace que un marco de datos existente sea más largo al convertir valores implícitos en valores existentes. Esto significa que las combinaciones de valores que no están presentes en los datos se crean como filas nuevas.

# NOTA: del resultado anterior, mirando el número de filas, Anna podría haber participado en 18 competiciones. ¿Pero podría ella? Es posible que vea que nos faltan algunos años. No hay datos de 2012 o 2014. Esto se debe a que complete solo funciona con los valores que ya están en los datos. Como ella nunca participó en una carrera en 2012, no vemos estas carreras. Sin embargo, podemos sumar estos valores si usamos vectores en lugar de columnas. Supongamos que queremos asegurarnos de que el marco de datos incluya todos los años entre 2010 y 2022 y los tres eventos en ejecución que ya están presentes en los datos:

running_races_anna %>%
    complete(year = 2010:2022, race) # Todas las combinaciones de valores que ya estaban presentes en los datos no cambiaron. Sin embargo, el código agregó filas que no estaban presentes. En otras palabras, agregó filas con años y carreras que no estaban presentes en el marco de datos original.

# NOTA: incluso podríamos ir tan lejos como para incluir nuevas carreras en el marco de datos (por ejemplo, ultramaratones):

running_races_anna %>%
    complete(year = 2010:2022, race = c(race, "ultra marathons")) # Mira cómo creamos un vector que incluye las carreras ya presentes en los datos más ultra maratones.

## La función expand ----

# NOTA: la función expand hace algo muy similar a la función complete anterior. Sin embargo, en lugar de agregar nuevas filas con el conjunto completo de valores, se crea un nuevo marco de datos solo para las columnas que especifique en la función (en comparación con complete, donde mantuvimos la columna de minutos):

running_races_anna %>%
    expand(year, race) # El resultado es un nuevo marco de datos. Puede ver que falta la columna minutos.

# NOTA: de manera similar a complete, podemos especificar un vector en lugar de una columna, por ejemplo, para asegurarnos de que el marco de datos cubra todos los años desde 2010 hasta 2022:

running_races_anna %>%
    expand(year = 2010:2022, race)

running_races_anna %>%
    expand(year = full_seq(year, 1), race) # Un buen truco para completar los años es la función full_seq. En este caso, full_seq generó el conjunto completo de años, comenzando con el año más bajo en el marco de datos y terminando con el año más alto. El 1 indica que los años deben incrementarse en 1 cada vez.

# NOTA: entonces tenemos un control sobre todas las combinaciones de años y carreras en nuestro marco de datos. Pero nos faltan los datos reales, es decir, los minutos que tomó Anna para estas carreras. Para agregar estos datos al marco de datos, combinamos expandir con full_join:

running_races_anna %>%
    expand(year = full_seq(year, 1), race) %>%
    full_join(running_races_anna, by = c("year", "race")) # Este marco de datos incluye las 39 carreras en las que Anna podría haber participado entre 2010 y 2022.

# Las funciones expand/complete con group_by ----

# NOTA: ahora imaginemos que Anna está corriendo en un club con otros tres corredores: Eva, John y Leonie:

running_races_club <- tribble(
    ~year, ~runner, ~race, ~minutes,
    2012, "Eva", "half marathon", 109,
    2013, "Eva", "marathon", 260,
    2022, "Eva", "half marathon", 120,
    2018, "John", "10km", 51,
    2019, "John", "10km", 49,
    2020, "John", "10km", 50,
    2019, "Leonie", "half marathon", 45,
    2020, "Leonie", "10km", 45,
    2021, "Leonie", "half marathon", 102,
    2022, "Leonie", "marathon", 220
    )

# NOTA: nuevamente, desea encontrar todas las carreras en las que cada corredor podría haber participado desde que se unió al club. Si usamos la misma técnica de expansión que acabamos de hacer, nos encontraremos con problemas:

all_running_races_club <- running_races_club %>%
    expand(year = full_seq(year, 1), race, runner) %>%
    glimpse()

# NOTA: tomemos a John, por ejemplo:

all_running_races_club %>%
    filter(runner == "John") # John se unió al club en 2019. Sin embargo, el marco de datos muestra las carreras perdidas de 2012. Esto se debe a que el marco de datos contiene las carreras de Eva, que se unió en 2012.

# NOTA: podemos solucionar el problema anterior agrupando el marco de datos por corredores:

all_running_races_club_correct <- running_races_club %>%
    group_by(runner) %>%
    expand(year = full_seq(year, 1), race = c("10km", "half marathon", "marathon")) %>%
    ungroup()

all_running_races_club_correct %>%
    filter(runner == "John") # Con group_by expandimos las filas solo dentro de los corredores. Si ahora observa los datos, notará que John no tiene carreras antes de 2018, que es exactamente lo que queremos.

# NOTA: usamos luego left_join para agregar los tiempos de ejecución al marco de datos expandido:

complete_running_races_club <- all_running_races_club_correct %>%
    left_join(running_races_club, by = c("year", "runner", "race")) %>%
    glimpse()

# NOTA: aunque con complete, el análisis se vuelve más sencillo:

running_races_club %>%
    group_by(runner) %>%
    complete(year = full_seq(year, 1), race = c("10km", "half marathon","marathon")) %>%
    ungroup()

## expandir el marco de datos con nesting ----

# NOTA: hasta ahora, hemos completado marcos de datos para filas faltantes. A veces, sin embargo, estamos interesados en las combinaciones únicas de valores en un marco de datos. Suponga que su club de corredores tiene 540 miembros. Quieres saber en qué competiciones ha participado un corredor durante su paso por el club. Esto es básicamente lo contrario de lo que acabamos de hacer. En lugar de encontrar todas las combinaciones de valores, buscamos las combinaciones únicas en un marco de datos dado. Para encontrar estas combinaciones podemos combinar expandir (expand) con anidar (nesting):

running_races_club %>%
    expand(nesting(runner, race)) # Puedes ver que Eva nunca ha corrido una carrera de 10 km y John nunca ha corrido una media maratón o una maratón.

# NOTA: para saber en qué carreras nunca han participado los corredores, además de la forma anterior (donde tenemos que inferir esa información del marco de datos, ya que los datos muestran lo que sucedió, no lo que no sucedió), podemos combinar el código con anti_join:

full_combinations_runners <- expand(running_races_club, runner, race = c("10km", "half marathon","marathon"))

full_combinations_runners %>%
    anti_join(running_races_club, by = c("runner", "race")) # El resultado de nuestro análisis ahora es más fácil de procesar, ya que ya no tenemos que buscar en el marco de datos las incógnitas conocidas y obtener los resultados deseados directamente.

## La función crossing ----

# NOTA: podríamos crear un marco de datos que represente el World Marathon Majors, que comenzó en el 2006. No tiene un marco de datos existente a mano, por lo que necesita crear uno desde cero. Para estos casos es necesario cruzar (crossing). La diferencia con las otras funciones anteriores es que con crossing no necesita un marco de datos existente. Usamos vectores en su lugar:

crossing(
    year = 2006:2022,
    races = c("Tokyo", "Boston", "Chicago", "London", "Berlin", "New York")
    ) # Los datos en sí solo nos dan un conjunto completo de combinaciones, por sí mismos no son muy significativos. El cruce suele ser un punto de partida para análisis posteriores. Imagínese si tuviéramos un conjunto de datos con todos los récords mundiales establecidos en estas carreras. Podríamos unir los récords mundiales a este marco de datos para determinar el porcentaje de carreras en las que se estableció un récord mundial en los seis majors.
