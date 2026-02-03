# ------------------------------------------------------------------------------
# run-all.R
# Ejecuta todo el pipeline de analisis en Posit Cloud
# ------------------------------------------------------------------------------
# Pasos:
#   1. Instalar paquetes (solo la primera vez)
#   2. Preparar datos y ejecutar analisis
# ------------------------------------------------------------------------------

# 1. Instalar y cargar paquetes
source("00-install-packages.R")

# 2. Ejecutar analisis completo
source("01-data-prep.R")
source("02-analysis.R")

cat("\n--- FIN ---\n")
