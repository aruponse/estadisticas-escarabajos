# ------------------------------------------------------------------------------
# 01-data-prep.R
# Preparacion de datos: lee Basefinal.xlsx y genera matrices para el analisis
# ------------------------------------------------------------------------------
# NOTA: Ajusta los nombres de columnas segun la estructura real de tu Excel.
# Las variables esperadas: localidad, abundancias por genero, latitud, longitud, altitud
# ------------------------------------------------------------------------------

library(readxl)
library(tidyverse)

# Ruta al archivo (ajustar si subes a otra carpeta en Posit Cloud)
data_file <- "Basefinal.xlsx"

if (!file.exists(data_file)) {
  stop("No se encuentra Basefinal.xlsx. Sube el archivo al directorio del proyecto en Posit Cloud.")
}

# Detectar hojas disponibles
sheets <- excel_sheets(data_file)
cat("Hojas en el archivo:", paste(sheets, collapse = ", "), "\n")

# Leer la primera hoja
raw_data <- read_excel(data_file, sheet = 1)

# --- INSPECCION Y AJUSTE MANUAL ---
# Revisa la estructura con: View(raw_data) o head(raw_data)
# Identifica las columnas que contienen:
#   - Nombre/localidad del sitio
#   - Coordenadas (lat, long) si existen
#   - Altitud si existe
#   - Abundancias por genero (columnas numericas)

# Nombres de columnas no-numericas (metadata)
# AJUSTAR segun tu archivo. Ejemplos comunes:
meta_cols <- c("Localidad", "localidad", "Sitio", "sitio", "Locality", "Site",
               "Latitud", "latitud", "Lat", "lat", "Latitude",
               "Longitud", "longitud", "Lon", "long", "Longitude",
               "Altitud", "altitud", "Alt", "alt", "Elevation", "elevation")

# Deteccion automatica: columnas de metadata vs abundancias
all_cols <- names(raw_data)
numeric_cols <- names(raw_data)[sapply(raw_data, is.numeric)]
meta_candidates <- all_cols[all_cols %in% meta_cols | 
                            grepl("locality|localidad|sitio|site|lat|long|alt", 
                                  tolower(all_cols))]
abundance_cols <- setdiff(numeric_cols, meta_candidates)

# Si hay columna de localidad tipo caracter
char_cols <- names(raw_data)[sapply(raw_data, is.character)]
locality_col <- intersect(char_cols, c("Localidad", "localidad", "Sitio", "sitio", 
                                       "Locality", "Site", "LocalityName"))
if (length(locality_col) == 0) locality_col <- char_cols[1]

# Construir matriz de abundancia: filas = localidades, columnas = generos
if (length(abundance_cols) > 0) {
  abundance_matrix <- as.matrix(raw_data[, abundance_cols])
  rownames(abundance_matrix) <- raw_data[[locality_col[1]]]
} else {
  # Fallback: columnas numericas excluyendo coordenadas/altitud
  exclude <- grep("lat|long|lon|alt|elev", names(raw_data), ignore.case = TRUE, value = TRUE)
  fallback_cols <- setdiff(numeric_cols, exclude)
  if (length(fallback_cols) == 0) fallback_cols <- numeric_cols
  abundance_matrix <- as.matrix(raw_data[, fallback_cols])
  rownames(abundance_matrix) <- raw_data[[locality_col[1]]]
}

# Eliminar filas sin datos
abundance_matrix <- abundance_matrix[rowSums(abundance_matrix, na.rm = TRUE) > 0, , drop = FALSE]

# Metadata: latitud, longitud, altitud (si existen)
has_lat <- any(grepl("lat", tolower(all_cols)))
has_long <- any(grepl("long|lon", tolower(all_cols)))
has_alt <- any(grepl("alt|elev", tolower(all_cols)))

lat_col <- all_cols[grepl("lat", tolower(all_cols))][1]
long_col <- all_cols[grepl("long|lon", tolower(all_cols))][1]
alt_col <- all_cols[grepl("alt|elev", tolower(all_cols))][1]

idx <- match(rownames(abundance_matrix), raw_data[[locality_col[1]]])
metadata <- data.frame(locality = rownames(abundance_matrix))
if (!is.na(lat_col) && lat_col %in% names(raw_data))  metadata$latitude  <- raw_data[[lat_col]][idx]
if (!is.na(long_col) && long_col %in% names(raw_data)) metadata$longitude <- raw_data[[long_col]][idx]
if (!is.na(alt_col) && alt_col %in% names(raw_data))  metadata$altitude  <- raw_data[[alt_col]][idx]

# Objetos exportados para el analisis
abundance_matrix
metadata
data_file
