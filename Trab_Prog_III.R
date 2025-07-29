# Instala los paquetes necesarios si no los tienes
required_packages <- c("DBI", "RMySQL", "dotenv", "dplyr", "ggplot2", "reshape2", "corrplot")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)

# Cargar librerías
library(DBI)
library(RMySQL)
library(dotenv)
library(dplyr)
library(ggplot2)
library(reshape2)
library(corrplot)

# Cargar variables de entorno desde archivo .env
load_dot_env(file = ".env")

# Leer variables
host <- Sys.getenv("MYSQL_HOST")
user <- Sys.getenv("MYSQL_USER")
password <- Sys.getenv("MYSQL_PASSWORD")
dbname <- Sys.getenv("MYSQL_DB")

# Conexión a la base de datos MySQL
con <- dbConnect(
  RMySQL::MySQL(),
  host = host,
  user = user,
  password = password,
  dbname = dbname
)

# Consulta para traer todos los datos de la tabla (ajusta el nombre de la tabla si es diferente)
query <- "SELECT * FROM estudiantes;"  # Cambia "studentsperformance" si tu tabla tiene otro nombre
df <- dbGetQuery(con, query)

# Mostrar primeras filas para verificar
print(head(df))

# Promedio de math_score por tipo de almuerzo ---
promedio_alimentos <- df %>%
  group_by(lunch) %>%
  summarise(promedio_math = mean(math_score, na.rm = TRUE))

ggplot(promedio_alimentos, aes(x = lunch, y = promedio_math, fill = lunch)) +
  geom_col(show.legend = FALSE) +
  labs(title = "Puntaje de Matemáticas por Tipo de Almuerzo",
       x = "Tipo de Almuerzo",
       y = "Promedio Puntaje Matemáticas") +
  theme_minimal()

# Boxplot por curso de preparación y puntaje de escritura ---
ggplot(df, aes(x = test_preparation_course, y = writing_score, fill = test_preparation_course)) +
  geom_boxplot(show.legend = FALSE) +
  labs(title = "Puntajes de Escritura según Preparación",
       x = "Curso de Preparación",
       y = "Puntaje Escritura") +
  theme_minimal()

# Histograma de puntajes de lectura ---
ggplot(df, aes(x = reading_score)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "black", alpha = 0.7) +
  labs(title = "Distribución de Puntajes de Lectura",
       x = "Puntaje de Lectura",
       y = "Frecuencia") +
  theme_minimal()

#  Scatterplot lectura vs escritura por género ---
ggplot(df, aes(x = reading_score, y = writing_score, color = gender)) +
  geom_point(alpha = 0.6) +
  labs(title = "Relación entre Puntaje de Lectura y Escritura por Género",
       x = "Puntaje Lectura",
       y = "Puntaje Escritura") +
  theme_minimal()



# Cerrar conexión
dbDisconnect(con)
