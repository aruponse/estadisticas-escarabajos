# ------------------------------------------------------------------------------
# 00-install-packages.R
# Instalacion de dependencias para el proyecto estadisticas-escarabajos
# Ejecutar UNA VEZ en Posit Cloud antes de correr el analisis
# ------------------------------------------------------------------------------

pkgs <- c(
  "readxl",      # Leer Basefinal.xlsx
  "iNEXT",       # Numeros Hill, rarefaccion/extrapolacion
  "vegan",       # vegdist, metaMDS, envfit, mantel
  "betapart",    # beta.pair, descomposicion Jaccard
  "tidyverse",   # Manipulacion de datos
  "gridExtra",   # Graficos combinados
  "viridis"      # Paleta de colores
)

for (pkg in pkgs) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
    library(pkg, character.only = TRUE)
  }
}

message("[OK] Paquetes instalados y cargados correctamente")
