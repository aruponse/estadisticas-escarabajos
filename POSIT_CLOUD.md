# Uso en Posit Cloud

Proyecto R para analisis de ensambles de escarabajos Pselaphinae segun objetivos.mdc.

## Requisitos

- Cuenta en [posit.cloud](https://posit.cloud)
- Archivo `Basefinal.xlsx` en tu equipo

## Pasos para ejecutar

### 1. Crear proyecto en Posit Cloud

1. Entra en [posit.cloud](https://posit.cloud)
2. Crea un nuevo proyecto (RStudio)
3. En el panel **Files**, sube todos los archivos del proyecto:
   - `Basefinal.xlsx`
   - `00-install-packages.R`
   - `01-data-prep.R`
   - `02-analysis.R`
   - `run-all.R`

### 2. Instalar paquetes (primera vez)

Abre la consola de R y ejecuta:

```r
source("00-install-packages.R")
```

Espera a que terminen de instalarse todas las dependencias.

### 3. Ejecutar el analisis

```r
source("run-all.R")
```

O bien, ejecuta en orden:

```r
source("01-data-prep.R")
source("02-analysis.R")
```

### 4. Entregables generados

Los resultados se guardan en la carpeta `output/`:

| Archivo | Descripcion |
|---------|-------------|
| `01_diversity_profile.pdf` | Perfil de diversidad (numeros Hill) |
| `02_rarefaction_extrapolation.pdf` | Curvas de rarefaccion/extrapolacion |
| `03_dendrogram_ward_braycurtis.pdf` | Dendrograma Ward, Bray-Curtis |
| `04_heatmap_abundances.pdf` | Heatmap de abundancias |
| `05_beta_components.pdf` | Reemplazo y anidamiento |
| `06_nmds_ordination.pdf` | Ordenacion NMDS |
| `07_nmds_envfit.pdf` | NMDS con variables ambientales |
| `hill_numbers_summary.csv` | Resumen de numeros Hill |
| `beta_decomposition_summary.csv` | Resumen beta (reemplazo/anidamiento) |
| `spearman_altitude_hill.csv` | Correlacion Spearman altitud-diversidad |
| `mantel_*.csv` | Resultados de pruebas Mantel |

### 5. Ajustar la estructura de datos

Si tu Excel tiene un formato distinto, edita `01-data-prep.R` y ajusta:

- **Columnas de abundancia**: nombres de los generos
- **Columna de localidad**: nombre del sitio
- **Latitud, longitud, altitud**: si existen con otros nombres

Revisa la estructura con:

```r
source("01-data-prep.R")
head(raw_data)
names(raw_data)
```

Luego modifica las variables `meta_cols`, `locality_col`, etc. segun corresponda.

## Formato esperado del Excel

- **Filas**: una por localidad/sitio (7 localidades segun objetivos)
- **Columnas**: 
  - Localidad/sitio (texto)
  - Abundancias por genero (numeros)
  - Opcional: latitud, longitud, altitud

## Problemas habituales

- **No encuentra Basefinal.xlsx**: sube el archivo al directorio raiz del proyecto y verifica que `getwd()` sea el directorio correcto.
- **Error en iNEXT o betapart**: asegurate de haber ejecutado `00-install-packages.R` antes.
- **Metadata vacia**: si no hay columnas de lat/long/alt, los analisis de envfit, Mantel y Spearman se omitiran; el resto funciona igual.
