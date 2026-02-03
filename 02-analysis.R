# ------------------------------------------------------------------------------
# 02-analysis.R
# Analisis estadistico completo segun objetivos.mdc
# Pselaphinae - Estructura y recambio taxonomico en bosques nublados del Norte de Ecuador
# ------------------------------------------------------------------------------
# Entregables:
#   1. Diversidad alfa (Hill) y perfiles - iNEXT
#   2. Dendrograma Ward + Bray-Curtis
#   3. Heatmap de abundancias
#   4. Descomposicion beta (reemplazo vs anidamiento) - betapart
#   5. NMDS + envfit + Mantel + correlacion Spearman altitud-diversidad
# ------------------------------------------------------------------------------

source("01-data-prep.R")

library(iNEXT)
library(vegan)
library(betapart)
library(tidyverse)
library(gridExtra)
library(viridis)

# Crear carpeta de salida
dir.create("output", showWarnings = FALSE)

# ==============================================================================
# 1. DIVERSIDAD ALFA - Numeros Hill (iNEXT)
# ==============================================================================
cat("\n[1] Analisis de diversidad alfa (iNEXT - Numeros Hill)...\n")

# iNEXT espera lista de abundancias por sitio
abund_list <- lapply(1:nrow(abundance_matrix), function(i) {
  x <- abundance_matrix[i, ]
  x[x > 0]
})
names(abund_list) <- rownames(abundance_matrix)

inext_out <- iNEXT(abund_list, q = c(0, 1, 2), datatype = "abundance", knots = 40)

# Guardar perfil de diversidad
pdf("output/01_diversity_profile.pdf", width = 8, height = 6)
ggiNEXT(inext_out, type = 1)
dev.off()

# Curvas de rarefaccion/extrapolacion
pdf("output/02_rarefaction_extrapolation.pdf", width = 10, height = 7)
ggiNEXT(inext_out, type = 3)
dev.off()

# Resumen Hill por localidad
hill_summary <- inext_out$AsyEst
write.csv(hill_summary, "output/hill_numbers_summary.csv", row.names = FALSE)

# ==============================================================================
# 2. DENDROGRAMA - Ward + Bray-Curtis
# ==============================================================================
cat("\n[2] Dendrograma jerarquico (Ward, Bray-Curtis)...\n")

bc_dist <- vegdist(abundance_matrix, method = "bray")
ward_clust <- hclust(bc_dist, method = "ward.D2")

pdf("output/03_dendrogram_ward_braycurtis.pdf", width = 8, height = 6)
plot(ward_clust, main = "Dendrograma - Ward, Bray-Curtis", xlab = "Localidad", sub = "")
dev.off()

# ==============================================================================
# 3. HEATMAP
# ==============================================================================
cat("\n[3] Heatmap de abundancias (escalado por filas)...\n")

mat_scaled <- scale(abundance_matrix)
mat_scaled[is.nan(mat_scaled)] <- 0

pdf("output/04_heatmap_abundances.pdf", width = 10, height = 7)
heatmap(t(mat_scaled), scale = "none", Rowv = NA, Colv = as.dendrogram(ward_clust),
        col = viridis(100), main = "Abundancias por genero (escalado por fila)",
        xlab = "Localidad", ylab = "Genero")
dev.off()

# ==============================================================================
# 4. DIVERSIDAD BETA - Reemplazo vs Anidamiento (Baselga, betapart)
# ==============================================================================
cat("\n[4] Descomposicion beta (Jaccard - reemplazo y anidamiento)...\n")

pa_matrix <- (abundance_matrix > 0) * 1
beta_pair <- beta.pair(pa_matrix, index.family = "jaccard")

# Dendrograma de cada componente
pdf("output/05_beta_components.pdf", width = 12, height = 4)
par(mfrow = c(1, 3))
plot(hclust(beta_pair$beta.jac, method = "ward.D2"), main = "Beta total (Jaccard)")
plot(hclust(beta_pair$beta.jtu, method = "ward.D2"), main = "Reemplazo (turnover)")
plot(hclust(beta_pair$beta.jne, method = "ward.D2"), main = "Anidamiento")
par(mfrow = c(1, 1))
dev.off()

# Resumen de disimilitudes
beta_summary <- data.frame(
  component = c("beta_total", "turnover", "nestedness"),
  mean = c(mean(as.matrix(beta_pair$beta.jac)[lower.tri(as.matrix(beta_pair$beta.jac))]),
           mean(as.matrix(beta_pair$beta.jtu)[lower.tri(as.matrix(beta_pair$beta.jtu))]),
           mean(as.matrix(beta_pair$beta.jne)[lower.tri(as.matrix(beta_pair$beta.jne))]))
)
write.csv(beta_summary, "output/beta_decomposition_summary.csv", row.names = FALSE)

# ==============================================================================
# 5. NMDS + ENVFIT + MANTEL + CORRELACION ALTITUD
# ==============================================================================
cat("\n[5] NMDS, envfit, Mantel y correlacion altitud-diversidad...\n")

set.seed(123)
nmds <- metaMDS(abundance_matrix, k = 2, distance = "bray", trymax = 100)

pdf("output/06_nmds_ordination.pdf", width = 8, height = 6)
plot(nmds, type = "t", main = "NMDS - Composicion Pselaphinae")
ordiellipse(nmds, groups = rownames(abundance_matrix), label = TRUE)
dev.off()

# envfit: proyeccion de variables ambientales (si existen)
env_vars <- NULL
if ("latitude" %in% names(metadata) && !all(is.na(metadata$latitude))) {
  env_vars <- cbind(env_vars, latitude = metadata$latitude)
}
if ("longitude" %in% names(metadata) && !all(is.na(metadata$longitude))) {
  env_vars <- cbind(env_vars, longitude = metadata$longitude)
}
if ("altitude" %in% names(metadata) && !all(is.na(metadata$altitude))) {
  env_vars <- cbind(env_vars, altitude = metadata$altitude)
}

if (!is.null(env_vars)) {
  env_fit <- envfit(nmds, env_vars, perm = 999)
  pdf("output/07_nmds_envfit.pdf", width = 8, height = 6)
  plot(nmds, type = "t", main = "NMDS con variables ambientales")
  plot(env_fit, p.max = 0.05, col = "darkblue")
  dev.off()
  cat("  envfit: variables ambientales proyectadas\n")
}

# Mantel: distancia composicional vs geografica/altitudinal
comp_dist <- vegdist(abundance_matrix, "bray")
if ("altitude" %in% names(metadata) && !all(is.na(metadata$altitude))) {
  alt_dist <- dist(metadata$altitude)
  mantel_alt <- mantel(comp_dist, alt_dist, method = "spearman", permutations = 999)
  cat("  Mantel (composicion vs altitud): r =", round(mantel_alt$statistic, 4), 
      ", p =", mantel_alt$signif, "\n")
  write.csv(data.frame(test = "Mantel_altitude", r = mantel_alt$statistic, p = mantel_alt$signif),
            "output/mantel_altitude.csv", row.names = FALSE)
}
if ("latitude" %in% names(metadata) && "longitude" %in% names(metadata) &&
    !all(is.na(metadata$latitude)) && !all(is.na(metadata$longitude))) {
  geo_dist <- dist(cbind(metadata$longitude, metadata$latitude))
  mantel_geo <- mantel(comp_dist, geo_dist, method = "spearman", permutations = 999)
  cat("  Mantel (composicion vs geografia): r =", round(mantel_geo$statistic, 4),
      ", p =", mantel_geo$signif, "\n")
  write.csv(data.frame(test = "Mantel_geography", r = mantel_geo$statistic, p = mantel_geo$signif),
            "output/mantel_geography.csv", row.names = FALSE)
}

# Correlacion Spearman: altitud vs numeros Hill por localidad
if ("altitude" %in% names(metadata) && !all(is.na(metadata$altitude)) &&
    "AsyEst" %in% names(inext_out)) {
  asy <- inext_out$AsyEst
  if (nrow(asy) > 0 && "Site" %in% names(asy) && "Diversity" %in% names(asy)) {
    value_col <- if ("Observed" %in% names(asy)) "Observed" else "Estimator"
    hill_wide <- asy %>% select(Site, Diversity, all_of(value_col)) %>%
      tidyr::pivot_wider(names_from = Diversity, values_from = all_of(value_col))
    meta_hill <- merge(metadata, hill_wide, by.x = "locality", by.y = "Site")
    hill_cols <- setdiff(names(meta_hill), c("locality", "latitude", "longitude", "altitude"))
    if (length(hill_cols) > 0) {
      spearman_results <- lapply(hill_cols, function(hc) {
        ct <- cor.test(meta_hill$altitude, meta_hill[[hc]], method = "spearman", exact = FALSE)
        data.frame(variable = hc, rho = as.numeric(ct$estimate), p = ct$p.value)
      })
      spearman_df <- do.call(rbind, spearman_results)
      write.csv(spearman_df, "output/spearman_altitude_hill.csv", row.names = FALSE)
      cat("  Spearman altitud vs Hill: ver output/spearman_altitude_hill.csv\n")
    }
  }
}

# ==============================================================================
# RESUMEN
# ==============================================================================
cat("\n[OK] Analisis completado. Entregables en la carpeta 'output/'\n")
list.files("output")
