# Estadisticas Escarabajos Pselaphinae

Analisis de la estructura y el recambio taxonomico de los ensambles de escarabajos errantes de hojarasca (Coleoptera: Staphylinidae: Pselaphinae) en bosques nublados andinos del Norte de Ecuador.

---

## Tabla de contenidos

- [Objetivos](#objetivos)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Requisitos](#requisitos)
- [Instalacion y uso](#instalacion-y-uso)
- [Formato de datos](#formato-de-datos)
- [Entregables](#entregables)
- [Plan de analisis estadistico](#plan-de-analisis-estadistico)
- [Referencias metodologicas](#referencias-metodologicas)
- [Solución de problemas](#solución-de-problemas)

---

## Objetivos

### Objetivo general

Analizar la estructura y el recambio taxonomico de los ensambles de escarabajos errantes de hojarasca (Coleoptera: Staphylinidae: Pselaphinae) en siete localidades de bosques nublados andinos del Norte de Ecuador.

### Objetivos especificos

1. Caracterizar la diversidad y estructura interna de los ensambles de generos de Pselaphinae en las siete localidades de estudio.
2. Determinar la contribucion relativa del reemplazo de generos y el anidamiento en la configuracion de la diversidad beta de Pselaphinae.
3. Evaluar la relacion entre la configuracion biotica y los factores geograficos/altitudinales de la region.

---

## Estructura del proyecto

```
estadisticas-escarabajos/
├── README.md                 # Este archivo
├── objetivos.mdc             # Especificacion detallada de objetivos y diseno
├── POSIT_CLOUD.md            # Instrucciones especificas para Posit Cloud
├── Basefinal.xlsx            # Datos de entrada (abundancias por localidad/genero)
├── 00-install-packages.R     # Instalacion de dependencias
├── 01-data-prep.R            # Lectura y preparacion de datos
├── 02-analysis.R             # Pipeline de analisis estadistico
├── run-all.R                 # Script maestro (ejecuta todo el pipeline)
└── output/                   # Carpeta de salida (generada al ejecutar)
    ├── 01_diversity_profile.pdf
    ├── 02_rarefaction_extrapolation.pdf
    ├── ...
    └── *.csv
```

---

## Requisitos

- **R** >= 4.0 (o entorno en la nube como Posit Cloud)
- **Archivo de datos**: `Basefinal.xlsx` con abundancias por localidad y genero

### Paquetes R utilizados

| Paquete    | Uso                                           |
|------------|-----------------------------------------------|
| readxl     | Lectura de archivos Excel                     |
| iNEXT      | Numeros Hill, rarefaccion y extrapolacion     |
| vegan      | Analisis ecológico (vegdist, metaMDS, envfit, mantel) |
| betapart   | Descomposicion beta (reemplazo/anidamiento)   |
| tidyverse  | Manipulacion de datos                         |
| gridExtra  | Composicion de graficos                       |
| viridis    | Paletas de colores                            |

---

## Instalacion y uso

### Opcion 1: Posit Cloud (recomendado si no tienes R instalado)

1. Accede a [posit.cloud](https://posit.cloud) y crea un nuevo proyecto RStudio.
2. Sube al proyecto:
   - `Basefinal.xlsx`
   - `00-install-packages.R`
   - `01-data-prep.R`
   - `02-analysis.R`
   - `run-all.R`
3. En la consola de R:

```r
source("00-install-packages.R")  # Solo la primera vez
source("run-all.R")
```

Consulta [POSIT_CLOUD.md](POSIT_CLOUD.md) para mas detalles.

### Opcion 2: R local o RStudio

1. Clona o descarga el proyecto.
2. Coloca `Basefinal.xlsx` en el directorio raiz.
3. Establece el directorio de trabajo: `setwd("ruta/al/proyecto")`
4. Ejecuta:

```r
source("00-install-packages.R")
source("run-all.R")
```

---

## Formato de datos

El archivo `Basefinal.xlsx` debe tener la siguiente estructura:

| Columna          | Tipo     | Descripcion                               |
|------------------|----------|-------------------------------------------|
| Localidad/Sitio  | texto    | Nombre o codigo de la localidad           |
| Genero_1, ...    | numerico | Abundancia de cada genero por localidad   |
| Latitud          | numerico | Opcional                                  |
| Longitud         | numerico | Opcional                                  |
| Altitud          | numerico | Opcional                                  |

- **Filas**: una por localidad (7 localidades segun el diseno del estudio).
- **Columnas de abundancia**: una por genero de Pselaphinae.
- Si los nombres de columnas difieren (ej. `Locality`, `latitude`), edita `01-data-prep.R` para ajustar la deteccion automatica.

---

## Entregables

Tras ejecutar el pipeline, se genera la carpeta `output/` con los siguientes archivos:

### Graficos (PDF)

| Archivo                          | Contenido                                                         |
|----------------------------------|-------------------------------------------------------------------|
| `01_diversity_profile.pdf`       | Perfil de diversidad (numeros Hill q=0, q=1, q=2) por localidad   |
| `02_rarefaction_extrapolation.pdf` | Curvas de rarefaccion y extrapolacion basadas en cobertura        |
| `03_dendrogram_ward_braycurtis.pdf` | Dendrograma jerarquico (Ward, Bray-Curtis)                      |
| `04_heatmap_abundances.pdf`      | Heatmap de abundancias escalado por filas                         |
| `05_beta_components.pdf`         | Dendrogramas de beta total, reemplazo y anidamiento               |
| `06_nmds_ordination.pdf`         | Ordenacion NMDS de la composicion por localidad                   |
| `07_nmds_envfit.pdf`             | NMDS con proyeccion de variables ambientales (si existen)         |

### Tablas (CSV)

| Archivo                          | Contenido                                           |
|----------------------------------|-----------------------------------------------------|
| `hill_numbers_summary.csv`       | Resumen de numeros Hill por localidad               |
| `beta_decomposition_summary.csv` | Promedios de beta total, reemplazo y anidamiento    |
| `spearman_altitude_hill.csv`     | Correlacion Spearman altitud vs diversidad          |
| `mantel_altitude.csv`            | Prueba Mantel: composicion vs distancia altitudinal |
| `mantel_geography.csv`           | Prueba Mantel: composicion vs distancia geografica  |

---

## Plan de analisis estadistico

### 1. Diversidad alfa (iNEXT)

- Numeros Hill: q=0 (riqueza), q=1 (Shannon), q=2 (Simpson).
- Rarefaccion y extrapolacion basadas en Sample Coverage para estandarizar comparaciones entre localidades.

### 2. Patrones de similitud

- **Dendrograma**: agrupamiento jerarquico Ward sobre matriz Bray-Curtis.
- **Heatmap**: abundancias escaladas por filas para identificar generos caracteristicos por localidad.

### 3. Diversidad beta (betapart)

- Marco Baselga (2010, 2012): separacion de beta total en reemplazo (turnover) y anidamiento mediante `beta.pair()` con indice Jaccard.

### 4. Factores geograficos y altitudinales

- **NMDS**: ordenacion en 2 dimensiones.
- **envfit**: proyeccion de latitud, longitud y altitud.
- **Mantel**: asociacion entre distancia composicional y distancias geograficas/altitudinales.
- **Spearman**: correlacion altitud vs numeros Hill por localidad.

---

## Referencias metodologicas

- Baselga A. (2010). Partitioning the turnover and nestedness components of beta diversity. *Global Ecology and Biogeography* 19: 134–143.
- Baselga A., Orme C.D.L. (2012). betapart: an R package for the study of beta diversity. *Methods in Ecology and Evolution* 3: 808–812.
- Chao A. et al. (2014). Rarefaction and extrapolation with Hill numbers. *Methods in Ecology and Evolution* 5: 380–392.
- Chiu C.-H., Chao A. (2014). Distance-based functional diversity measures and their decomposition. *Ecography* 37: 449–457.
- Hsieh T.C. et al. (2016). iNEXT: an R package for rarefaction and extrapolation of species diversity. *Methods in Ecology and Evolution* 7: 1451–1456.
- Jost L. (2007). Partitioning diversity into independent alpha and beta components. *Ecology* 88: 2427–2439.
- Legendre P., Legendre L. (2013). *Numerical Ecology*. 3rd ed. Elsevier.
- Oksanen J. et al. (2020). vegan: Community Ecology Package. R package.
- Ward J.H. (1963). Hierarchical grouping to optimize an objective function. *Journal of the American Statistical Association* 58: 236–244.

---

## Solución de problemas

| Problema                         | Solucion                                                       |
|----------------------------------|----------------------------------------------------------------|
| No encuentra `Basefinal.xlsx`    | Verifica que el archivo este en el directorio de trabajo (`getwd()`). |
| Error al cargar iNEXT, betapart… | Ejecuta primero `source("00-install-packages.R")`.             |
| Metadata vacia (lat, long, alt)  | Los analisis de envfit, Mantel y Spearman se omiten; el resto se ejecuta. |
| Estructura del Excel diferente   | Edita `01-data-prep.R` y ajusta `meta_cols`, `locality_col`, etc. |

---

## Diseno metodologico

Estudio descriptivo, cuantitativo, no experimental, observacional y transversal. Los datos provienen de colecciones cientificas (muestreo pasivo, esfuerzo heterogeneo). Las conclusiones son exploratorias, orientadas a caracterizar patrones ecologicos observados a partir de los registros.
