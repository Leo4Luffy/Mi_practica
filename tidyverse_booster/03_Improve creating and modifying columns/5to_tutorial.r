# Tutorial "Cómo ordenar los niveles de los factores"

pacman::p_load('tidyverse')

# NOTA: un factor es una estructura de datos ordenada en R. Lo que se ordena en un factor son sus niveles. Por lo general, necesita saber el orden de los niveles cuando intenta visualizar columnas de factores. Digamos que desea ordenar las barras en su gráfico de barras. O desea ordenar las líneas en su gráfico de líneas. A continuación profundizaremos en cuatro funciones del paquete forcats que nos permiten ordenar los niveles de los factores:

# - fct_relevel.
# - fct_infreq.
# - fct_reorder.
# - fct_reorder2.

## Cómo ordenar los niveles de los factores manualmente ----

# NOTA: suponga que quiere crear un gráfico de barras que muestra cuántas horas duermen las vacas, los perros, los tigres y los chimpancés por día:

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    ggplot(aes(x = name, y = sleep_total)) +
    geom_col()

# NOTA: supongamos que quiere poner vacas y perros primero en el gráfico de barras. Aquí está la misma columna como un factor:

animal_factor <- as.factor(c('Cow', 'Dog', 'Tiger', 'Chimpanzee'))
levels(animal_factor) # Se puede ver cómo se organizan los niveles de los factores. Si vuelve a mirar nuestro gráfico de barras, notará que la salida tiene el mismo orden que las barras en el gráfico de barras.

# NOTA: Podemos cambiar este orden manualmente usando la función fct_relevel. En esencia, estamos poniendo algunos niveles frente a otros con fct_relevel:

fct_relevel(.f = animal_factor, c('Cow', 'Dog')) # El primer argumento es la columna del factor. Luego enumera los niveles que desea colocar primero.

# NOTA: intentemos esto en nuestra visualización:

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = fct_relevel(name, c('Cow', 'Dog'))) %>% # Se quiso poner las vacas y los perros primero. Tal vez se pregunte por qué esquema están ordenados los otros niveles. Por defecto por orden alfabético. En nuestro caso, la “C” de “Chimpancé” precede a la “T” de “Tigre”.
    ggplot(aes(x = name, y = sleep_total)) +
    geom_col()

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = fct_relevel(name, c('Cow', 'Dog'))) %>%
    ggplot(aes(x = sleep_total, y = name)) + # Si ponemos el factor en el eje y y las horas de sueño en el eje x, podemos ver que los valores están ordenados de abajo hacia arriba y no de arriba hacia abajo.
    geom_col()

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = fct_relevel(name, 'Cow', after = 3)) %>% # Aquí hay otro truco interesante. En lugar de colocar los niveles al frente, podemos colocarlos donde queramos con el argumento posterior. Supongamos que queremos colocar la Vaca después del Tigre. Me gustaría que pudieras usar una cadena para el argumento posterior, pero debes especificar un número. Sus niveles se colocarán en la posición n + 1 de este número. En nuestro caso la vaca se coloca en la 4ª posición (3ª+1).
    ggplot(aes(x = name, y = sleep_total)) +
    geom_col()

## Cómo ordenar los niveles según la frecuencia con la que ocurre cada nivel ----

# NOTA: tomemos el marco de datos mpg con la columna del fabricante:

mpg %>%
    count(manufacturer)

# NOTA: ahora supongamos que queremos mostrar cuántas veces aparece cada fabricante en el marco de datos:

mpg %>%
    ggplot(aes(x = manufacturer)) +
    geom_bar() +
    scale_x_discrete(guide = guide_axis(n.dodge = 2))

# NOTA: con la función fct_infreq podemos cambiar el orden según la frecuencia con la que ocurre cada nivel:

mpg %>%
    mutate(manufacturer = fct_infreq(manufacturer)) %>%
    ggplot(aes(x = manufacturer)) +
    geom_bar() +
    scale_x_discrete(guide = guide_axis(n.dodge = 2))

mpg %>%
    mutate(manufacturer = fct_infreq(manufacturer) %>% fct_rev) %>% # Si desea invertir el orden de los niveles, puede utilizar la función fct_rev.
    ggplot(aes(x = manufacturer)) +
    geom_bar() +
    scale_x_discrete(guide = guide_axis(n.dodge = 2))

## Cómo ordenar los niveles en función de los valores de una variable numérica ----

# NOTA: hasta ahora, hemos cambiado el orden de los niveles basándonos únicamente en la información de la columna de factores. A continuación, analicemos cómo podemos ordenar los niveles de una columna de factores en función de otra variable numérica.

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    ggplot(aes(x = name, y = sleep_total)) +
    geom_col() # Podemos ver que cada nivel de factor está asociado a la variable continua sleep_total.

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = as.factor(name) %>% fct_reorder(sleep_total)) %>% # La función fct_reorder permite ordenar los niveles en función de otra variable continua. En nuestro caso, sleep_total. Las vacas aparentemente tienen la menor cantidad de horas de sueño, seguidas por los perros, los chimpancés y los tigres.
    pull(name)

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = as.factor(name) %>% fct_reorder(sleep_total)) %>%
    ggplot(aes(x = name, y = sleep_total)) + # Lo anterior se puede visualizar así.
    geom_col()

# NOTA: podemos invertir el orden de lo hecho anteriormente, configurando el argumento .desc en TRUE:

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = as.factor(name) %>% fct_reorder(sleep_total, .desc = TRUE)) %>% # 
    ggplot(aes(x = name, y = sleep_total)) + # Lo anterior se puede visualizar así.
    geom_col()

# NOTA: también podemos invertir el orden de lo hecho anteriormente, con la función fct_rev:

msleep %>%
    filter(name %in% c('Cow', 'Dog', 'Tiger', 'Chimpanzee')) %>%
    mutate(name = as.factor(name) %>% fct_reorder(sleep_total) %>% fct_rev()) %>%
    ggplot(aes(x = name, y = sleep_total)) + # Lo anterior se puede visualizar así.
    geom_col()

## Cómo ordenar niveles en función de los valores de dos variables numéricas ----

# NOTA: ¿Alguna vez ha creado un gráfico de líneas y descubrió que el final de sus líneas no está alineado con el texto de la leyenda? Por ejemplo el siguiente:

gss_cat %>%
    count(age, marital) %>%
    group_by(age) %>%
    mutate(prop = n / sum(n)) %>%
    ungroup() %>%
    ggplot(aes(x = age, y = prop, color = marital)) +
    stat_summary(geom = 'line', fun = mean) # Como puede ver, la línea azul termina en la parte superior, pero el primer elemento de la leyenda es la categoría "No answer".

# NOTA: podemos mejorar el orden de la leyenda (también conocido como los niveles) usando la función fct_reorder2:

gss_cat %>%
    count(age, marital) %>%
    group_by(age) %>%
    mutate(prop = n / sum(n)) %>%
    ungroup() %>%
    mutate(marital = as.factor(marital) %>% fct_reorder2(age, prop)) %>%
    ggplot(aes(x = age, y = prop, color = marital)) +
    stat_summary(geom = "line", fun = mean)

# NOTA: en esencia, la función hace lo siguiente: encuentra los valores más grandes de una variable en el valor más grande de otra variable. En este caso, buscamos el mayor valor de prop dentro del mayor valor de edad:

gss_cat %>%
    count(age, marital) %>%
    group_by(age) %>%
    mutate(prop = n / sum(n)) %>%
    ungroup() %>%
    group_by(marital) %>%
    slice_max(age) %>%
    ungroup() %>%
    arrange(desc(prop)) # Por ejemplo, el mayor valor de prop para el mayor valor de edad es 0,73. Este nivel debería, por lo tanto, estar en la parte superior de nuestra leyenda como se ve en el gráfico anterior.
