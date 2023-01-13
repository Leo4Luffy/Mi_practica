# Tutorial "Cómo cambiar el nombre de muchos nombres de columna a la vez"

pacman::p_load('tidyverse')

Datos <- tribble(
    ~'Age', ~'Item 1', ~'Item 2', ~'$dollars', ~'Where do you come from?',
    23, 4, 8, 45, 'Germany'
    ) # Los nombres de las columnas a menudo contienen espacios, caracteres especiales o se escriben en una combinación de caracteres en mayúsculas y minúsculas. Dichos nombres de columna con un formato deficiente pueden generar numerosos problemas. En este conjunto de datos:

# 1. Los nombres de las columnas Item 1 y Item 2 contienen espacios. Si tuviéramos que referirnos a estas columnas en R, tendríamos que encerrarlas entre comillas simples. Esto es mucho más complicado de escribir que simplemente Item_1. Lo mismo sucede con la última columna. Aquí el nombre de la columna no es solo una palabra, sino una oración completa.
# 2. La columna $dollars comienza con un signo $. Sin embargo, los nombres de las columnas no pueden comenzar con un carácter especial en R. Tendríamos que eliminar el signo de dólar del nombre de la columna.
# 3. La primera letra de algunos nombres de columnas se escribe en mayúsculas. Esto no debe ser un problema, pero creo que generalmente es más fácil escribir los nombres de las columnas en minúsculas.
# 4. También vemos un patrón. Los nombres de columna Item 1 e Item 2 difieren solo por su número. Por lo tanto, sería bueno si pudiéramos cambiar el nombre de estas columnas a la vez.

# NOTA: Podríamos resolver fácilmente los problemas anteriores con la función "rename":

Datos %>%
    rename(
        age = Age,
        item_1 = 'Item 1',
        item_2 = 'Item 2',
        dollars = '$dollars',
        origin = 'Where do you come from?'
        )

# NOTA: Sin embargo, imagínese cuánto tiempo tomaría si tuviera 50 nombres de columna para cambiar usando la función de cambio de nombre. Así que obviamente necesitamos una mejor solución. Y la solución es la función "rename_with":

mpg %>%
    rename_with(
        data = .,
        .fn = toupper,
        .cols = everything()
        ) %>%
        colnames() # La principal diferencia entre rename y rename_with es que rename_with cambia los nombres de las columnas usando una función. Los tres argumentos principales de la función son .data, .fn y .cols. .data representa el marco de datos, .fn para la función que se aplicará a los nombres de las columnas y .cols para las columnas a las que se aplicará la función. En este ejemplo, utilicé la función toupper para convertir todos los nombres de las columnas a mayúsculas. Esencialmente, rename_with no hace nada más que usar los nombres de las columnas como un vector de cadenas.

iris %>%
    rename_with(
        ~ janitor::make_clean_names(., case = 'big_camel')
        ) %>%
        colnames() # Otro ejemplo es usando la función make_clean_names del paquete janitor. Dado que esta es una función que funciona con un vector de cadenas, podemos usar esta función para escribir todos los nombres de columna del marco de datos del iris en notación BigCamel.

mpg %>%
    rename_with(
        ~ gsub('e', '_', .)
        ) %>%
        colnames() # Otro caso de uso de rename_with es el reemplazo de caracteres. Supongamos que queremos reemplazar todos los caracteres e con un guión bajo _.

mpg %>%
    rename_with(
        ~ str_replace(., 'e', '_')
        ) %>%
        colnames() # Otra forma de hacer lo anterior, usando la función str_replace.

anscombe %>% # Los nombres de las columnas del conjunto de datos de "Anscombe" consisten en la letra x o y y los números del 1 al 4.
    rename_with(
        ~ str_replace(., pattern = '(\\d+)', replacement = '_\\1')
        ) %>%
        colnames() # Supongamos que queremos insertar un guión bajo entre la letra y el número. Un truco para resolver este problema es usar la función de agrupación en str_replace.

# NOTA: respecto al código anterior, con pattern decimos que estamos buscando un grupo de caracteres que contengan uno o más dígitos (\\d+). \\d+ es una expresión regular. Si desea obtener más información al respecto, eche un vistazo a la documentación oficial de stringr (https://stringr.tidyverse.org/articles/regular-expressions.html). Con replacement dijimos que queremos poner un guión bajo al frente de este grupo. El grupo en sí está especificado por \\1. Si tuviéramos dos grupos, el segundo grupo estaría especificado por \\2.

anscombe %>%
    rename_with(
        ~ str_replace(., pattern = '(y)([1-2])', replacement = '\\1psilon\\2_')
        ) %>%
        colnames() # Si queremos reemplazar solo los nombres de columna y1 e y2 con ypsilon1_ e ypsilon2_. Si solo usamos las técnicas que hemos aprendido hasta ahora, necesitamos crear dos grupos. El primer grupo se usa para reemplazar la y con ypsilon. El segundo grupo se usa para reemplazar el número con el número y un guión bajo:

# NOTA: respecto al código anterior, puede ver que cambiamos el nombre de solo dos de las ocho columnas. Esto se debe a que el patrón utilizado en str_replace solo se aplica a dos variables: las variables que comienzan con una y y van seguidas de los números 1 o 2. También puede ver que usamos dos grupos. El primer grupo contiene la letra y, el segundo grupo contiene el número 1 o 2 (indicado por los corchetes [1-2]). En el argumento de reemplazo, encontrará estos grupos como \\1 y \\2. Si elimináramos estos grupos en el argumento de reemplazo, se eliminarían de los nuevos nombres de columna (y arrojaría un error porque los nombres de columna ya no serían únicos).

mpg %>%
    rename_with(
        ~ toupper(.), where(is.numeric)
        ) %>%
        colnames() # De manera similar, podría usar una función tidyselect y convertir todas las columnas numéricas a mayúsculas.

iris %>%
    rename_with(
        ~ str_replace(., pattern = '\\.', '_'), starts_with('Sepal')
        ) %>%
        colnames() # O podría reemplazar un punto con un guión bajo para todas las columnas que comienzan con la palabra Sepal.

iris %>%
    rename_with(~ str_replace(., pattern = '\\.', '_'), matches('[Ww]idth$')
    ) %>%
    colnames() # Otra función útil son los matches. Con matches, puede buscar patrones específicos en los nombres de sus columnas y aplicar una función a los nombres de las columnas que coincidan con el patrón. En el siguiente ejemplo, usamos esta técnica para reemplazar el punto con un guión bajo en todos los nombres de columna que terminan con "Width" o "width".
