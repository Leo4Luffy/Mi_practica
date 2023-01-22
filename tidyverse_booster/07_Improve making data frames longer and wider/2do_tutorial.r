# Tutorial "Cómo hacer un marco de datos más ancho"

pacman::p_load('tidyverse')

# NOTA: en el último tutorial, dijimos que muchos conjuntos de datos se hacen más largos para que estén ordenados. Los datos ordenados son legibles por máquina en el sentido de que están optimizados para ser procesados por herramientas de análisis de datos. Como resultado, los marcos de datos más largos tienen más valores que los más cortos y son más fáciles de analizar con R. Sin embargo, a veces queremos hacer lo contrario y ampliar los marcos de datos. La mayoría de los casos de uso es que los marcos de datos más amplios son más legibles para los humanos, ya sea cognitivamente o para presentaciones.

## Cómo usar pivot_wider (el ejemplo más simple) ----

# NOTA: el marco de datos fish_encounters contiene información sobre varias estaciones que monitorean y registran la cantidad de peces que pasan por estas estaciones río abajo:

fish_encounters # El marco de datos tiene tres columnas. fish es un identificador de especies de peces específicas. station es el nombre de la estación de medición. seen indica si se vio un pez (1 en caso afirmativo) o no (NA en caso contrario) en esta estación.

# NOTA: suponga que desea ampliar este marco de datos porque desea presentar los resultados en una tabla legible por humanos. Para hacer esto, puede usar pivot_wider y proporcionar argumentos para sus parámetros principales:

fish_encounters_wide <- fish_encounters %>%
    pivot_wider(
        id_cols = fish,
        names_from = station,
        values_from = seen
        ) %>%
    print() # id_cols: estas columnas son los identificadores de las observaciones. Estos nombres de columna permanecen sin cambios en el marco de datos. Sus valores forman las filas del marco de datos transformado. De forma predeterminada, todas las columnas excepto las especificadas en names_from y values_from se convierten en id_cols; names_from: estas columnas se transformarán en un formato más amplio. Sus valores se convertirán en columnas. Si especifica más de una columna para names_from, los nombres de columna recién creados serán una combinación de los valores de columna; values_from: Los valores de estas columnas se usarán para las columnas creadas con names_from.

# NOTA: una pequeña mejora en el marco de datos podría ser agregar un prefijo a los nuevos nombres de columna:

fish_encounters %>%
    pivot_wider(
        id_cols = fish,
        names_from = station,
        values_from = seen,
        names_prefix = "station_"
        ) %>%
    print()

fish_encounters %>%
    pivot_wider(
        id_cols = fish,
        names_from = station,
        values_from = seen,
        names_glue = "station_{station}" # Otra forma de hacer lo anterior sería usar names_glue. names_glue toma una cadena con llaves. Dentro de las llaves pones las columnas de names_from. El contenido dentro de las llaves se reemplaza por los nuevos nombres de columna.
        ) %>%
    print()

## Cómo usar pivot_wider para calcular proporciones/porcentajes ----

# NOTA: suponga que ha obtenido el siguiente conjunto de datos sobre los alquileres y los ingresos de los residentes de EE. UU.:

us_rent_income # La variable variable contiene dos valores: rent y income. El alquiler estimado real y los ingresos estimados se almacenan en la variable estimate. El valor de income indica el ingreso anual medio. Los valores de rent indican el ingreso mensual medio. moe indica el margen de error para estos valores.

# NOTA: claramente, el marco de datos anterior está desordenado ya que los ingresos y el alquiler deben estar en dos columnas. Supongamos que desea averiguar qué porcentaje de sus ingresos les queda a las personas en diferentes estados para pagar el alquiler. Una forma subóptima sería una combinación de mutate con case_when y lead:

us_rent_income %>%
    select(-moe) %>%
    mutate(
        estimate = case_when(
            variable == "income" ~ estimate,
            variable == "rent" ~ estimate * 12
            ),
        lead_estimate = lead(estimate),
        rent_percentage = (lead_estimate / estimate) * 100
        ) # Los porcentajes que estábamos buscando se pueden encontrar en la columna rent_percentage. Sus valores nos dicen dos cosas: qué porcentaje de la renta mantienen las personas en relación con sus ingresos anteriores y qué porcentaje de sus ingresos era en relación con su renta. Una vez más, creamos un conjunto desordenado. Otro problema con este enfoque es que hacemos una suposición con lead. Suponemos que los valores renta y alquiler se alternan en la columna de variables.

# NOTA: una mejor opción es ampliar el marco de datos y calcular el porcentaje del conjunto de datos más amplio:

us_rent_income %>%
    pivot_wider(
        id_cols = c(GEOID, NAME),
        names_from = "variable",
        values_from = "estimate"
        ) %>%
    mutate(
        rent = rent * 12,
        percentage_of_rent = (rent / income) * 100
        ) # Este enfoque tiene tres ventajas sobre el enfoque anterior. Primero, obtenemos un conjunto de datos ordenado. En segundo lugar, no dependemos de la suposición de que los valores de renta y renta se alternan. En tercer lugar, es menos exigente cognitivamente. Dado que cada columna contiene una variable, no necesitamos preocuparnos por lo que representan esos valores. Simplemente dividimos un valor por el otro y lo multiplicamos por 100.

## Cómo usar pivot_wider para crear tablas de estadísticas de resumen ----

# NOTA: las estadísticas resumidas generalmente se presentan en documentos, carteles y presentaciones. Dado que hay una cantidad limitada de espacio disponible en estos formatos, se presentan en tablas más anchas. Como ya habrá escuchado, los marcos de datos más amplios tienen menos valores que los más largos. En el siguiente ejemplo, reduciremos el número de valores de 105 a 40 ampliando el marco de datos. En otras palabras, estamos haciendo que las estadísticas resumidas de los datos sean más legibles para los humanos:

means_diamonds <- diamonds %>%
    group_by(cut, color) %>%
    summarise(
        mean = mean(price)
        ) %>% # Suponga que desea trazar los precios promedio de los diamantes con diferentes tallas y colores. Los calcula con group_by y summarise. Como puede ver, el marco de datos tiene 35 ∗ 3 = 105 valores.
    print()

means_diamonds %>%
    pivot_wider(
        id_cols = cut,
        names_from = color,
        values_from = mean,
        names_prefix = "mean_"
        ) # Transformamos el marco de datos con pivot_wider. Aquí reducimos el marco de datos a 40 valores, haciendolo más legible para que los lectores puedan encontrar cada valor rápidamente.

## Cómo ampliar los marcos de datos para su uso en otras herramientas de software ----

# NOTA: suponga que realizó un experimento para probar si la cafeína tiene un efecto en el tiempo de los corredores de 100 metros. Dos grupos corrieron 100 metros dos veces con un descanso de 30 minutos. En la segunda carrera, el grupo de tratamiento recibió un refuerzo de cafeína 10 minutos antes de la carrera, mientras que el grupo de control no. También se midió la cadencia de los corredores, es decir, el número de pasos que dan en un minuto. Cada corredor es identificable de forma única por una identificación:

runners_data <- tibble(
    id = as.numeric(gl(6, 2)),
    group = c(rep("treatment", 6), rep("control", 6)),
    measurement = c(rep(c("pre", "post"), 6)),
    speed = rnorm(12, mean = 12, sd = 0.5),
    cadence = rnorm(12, mean = 160, 3)
    ) %>%
    print()

# NOTA: digamos que necesita analizar los datos anteriores utilizando un software basado en GUI. Con dicho software y tales condiciones experimentales, no es raro que necesite ampliar el marco de datos para comparar los valores previos y posteriores de una variable. Para mantener toda la información del marco de datos, necesitamos pasar las columnas de velocidad y cadencia a values_from:

runners_data %>%
    pivot_wider(
        id_cols = c(id, group),
        names_from = measurement,
        values_from = c(speed, cadence)
        ) # La función creó cuatro nuevas columnas. ¿Por qué cuatro? Primero cuenta el número de valores únicos en la variable especificada en names_from. Luego, multiplica este número por el número de columnas especificadas en values_from: 2 ∗ 2 = 4.

# NOTA: podemos mejorar estéticamente los nombres de estas columnas con names_sep y names_glue. Comencemos con names_sep, ya que aún no lo hemos visto. Si pasa más de una columna a values_from, el parámetro especifica cómo une los valores. En nuestro caso con un punto (.):

runners_data %>%
    pivot_wider(
        id_cols = c(id, group),
        names_from = measurement,
        values_from = c(speed, cadence),
        names_sep = "."
        )

# NOTA: también puedes cambiar el orden de los valores con names_glue:

runners_data %>%
    pivot_wider(
        id_cols = c(id, group),
        names_from = measurement,
        values_from = c(speed, cadence),
        names_glue = "{measurement}.{.value}"
        ) # .value es un marcador de posición para los nombres de columna especificados en values_from. Como le pasamos speed y cadence al parámetro, .value se reemplaza por estos dos valores.

# NOTA: no solo el software GUI como SPSS a veces necesita datos más amplios para ejecutar pruebas estadísticas. También R tiene algunas funciones estadísticas que necesitan datos más amplios (ver t.test). Por lo tanto, pivot_wider a menudo se necesita en equipos que usan R en combinación con programas basados en GUI o para análisis estadísticos.
