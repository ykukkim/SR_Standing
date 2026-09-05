# Environment Setting ----
rm(list = ls()) # clears the environment - the one with the variables.
# Libraries ----
#install.packages("pacman")
pacman::p_load(
  readxl,
  openxlsx,
  grid,
  ggplot2,
  devtools,
  ggpubr,
  dplyr,
  tidyr,
  car,
  agricolae,
  FSA,
  DescTools,
  rmatio,
  dunn.test,
  ez,
  tidyverse,
  afex,
  emmeans,
  multcomp,
  lmerTest,
  lme4,
  patchwork
)
# Environment Setting ----
os <- Sys.info()["sysname"]

# Set directory paths based on the operating system
if (os == "Windows") {
  # Path for Windows
  setwd("//hest.nas.ethz.ch/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/SR_YKK//Codes//02_Statistic_analysis//R")
  sr_data <- "//hest.nas.ethz.ch/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/SR_YKK/Results/Stat_Results/RawData"
  output_directory_path <- "//hest.nas.ethz.ch/green_groups_lmb_public/Projects/NCM/NCM_EXP/NCM_STM/NCM_STR/SR_YKK/Results/Stat_Results"
} else if (os == "Darwin") {
  setwd("/Users/yonkim/Desktop/SR/02_Statistic_analysis//R")
  sr_data <- "/Users/yonkim/Desktop/SR/Result/Hilbert_TJ2sec/Stat_Results/RawData"
  sr_data_cop <- "/Users/yonkim/Desktop/SR/Result/Hilbert_TJ2sec"
  cop_path <- paste(sr_data_cop, "copParameters.xlsx", sep = "/")
  cop_spectra <- paste(sr_data_cop, "copspectra.xlsx", sep = "/")
  output_directory_path <- "/Users/yonkim/Desktop/SR/Result/Hilbert_TJ2sec/Stat_Results/CopEMG"
} else {
  stop("Unsupported OS")
}

source("./00_Functions/utilities_copemg.R")

# EMG Data ----

Conditions <- c('ECHard', 'ECFoam', 'ECFoam1Hz', 'ECFoam1HzWN')
band_order <- c("Delta", "Theta", "Alpha", "Beta", "Gamma")
muscle_pair_interested <- c("SOL_L_SOL_R","SOL_L_TAN_L","SOL_L_GAL_L","TAN_L_GAL_L","SOL_R_TAN_R","SOL_R_GAL_R","TAN_R_GAL_R","TAN_L_TAN_R","GAL_L_GAL_R")
interemgcoherence <- read.mat(paste0(sr_data, '/', 'coherence_band_results_mean.mat'))
results <- extract_data(interemgcoherence,muscle_pair_interested)

# CoP Paramters ----
data_all_parameters  <- read.xlsx(cop_path)
data_all_parameters <- data_all_parameters %>%
  dplyr::select(-session, -swayArea_rel, -rmsDist_r, -meanDist_r, -meanVel_r, -peakVel_r) %>%
  filter(!stim %in% c("S03_vibratory", "S04_notrigger")) %>%
  mutate(
    stim = case_when(
      stim == "S01_notrigger" ~ "ECHard",
      stim == "S02_notrigger" ~ "ECFoam",
      stim == "S03_neutral"   ~ "ECFoam1Hz",
      stim == "S03_auditory"  ~ "ECFoam1HzWN",
      TRUE ~ stim  # Keeps original value if none of the above conditions are met
    )
  )

# Read CoP Spectra Data ----

sheet_names <- excel_sheets(cop_spectra)
data_all_spectra <- setNames(
  lapply(sheet_names, function(sheet) read_excel(cop_spectra, sheet = sheet)),
  sheet_names
)

# Ensure output directory path ends with a slash and create if it doesn't exist ----
if (!grepl("/$", output_directory_path)) {
  output_directory_path <- paste0(output_directory_path, "/")
}

if (!dir.exists(output_directory_path)) {
  dir.create(output_directory_path, recursive = TRUE)
  message("Directory created: ", output_directory_path)
} else {
  message("Directory already exists: ", output_directory_path)
}


# Cop and EMG stat for each window method ----
window_method_data <- list()
for (window_method in names(results[["extracted_data"]])){

  temp_data <- data_all_spectra[[window_method]] %>%
    filter(!stim %in% c("S03_vibratory", "S04_notrigger"))

  temp_data <- temp_data %>%
    mutate(
      stim = case_when(
        stim == "S01_notrigger" ~ "ECHard",
        stim == "S02_notrigger" ~ "ECFoam",
        stim == "S03_neutral"   ~ "ECFoam1Hz",
        stim == "S03_auditory"  ~ "ECFoam1HzWN",
        TRUE ~ stim  # Keeps original value if none of the above conditions are met
      )
    )

  df <- results$extracted_data[[window_method]] %>%
    group_by(muscle, trial, band, condition) %>%
    # do(remove_outliers(., "coherence_value")) %>%
    filter(condition %in% Conditions) %>%
    filter(if_all(everything(), ~ !is.nan(.)))  # Remove rows with NaN in any column

  df_variability <- results$variability_data[[window_method]] %>%
    group_by(muscle, band, condition) %>%
    # do(remove_outliers(., "variability_value")) %>%
    filter(condition %in% Conditions) %>%
    filter(if_all(everything(), ~ !is.nan(.)))  # Remove rows with NaN in any column

  df <- df %>%
    mutate(
      band = case_when(
        band == "delta" ~ "Delta",
        band == "theta" ~ "Theta",
        band == "alpha" ~ "Alpha",
        band == "beta"  ~ "Beta",
        band == "gamma" ~ "Gamma",
        TRUE ~ band  # Keeps original value if none of the above conditions are met
      )
    )

  df_variability <- df_variability %>%
    mutate(
      band = case_when(
        band == "delta" ~ "Delta",
        band == "theta" ~ "Theta",
        band == "alpha" ~ "Alpha",
        band == "beta"  ~ "Beta",
        band == "gamma" ~ "Gamma",
        TRUE ~ band  # Keeps original value if none of the above conditions are met
      )
    )

  # Mean coherence values
  filtered_data_all <- process_spectra_data(temp_data)

  window_method_data[[window_method]] <- list(
    df = df,
    df_variability = df_variability,
    filtered_data_all = filtered_data_all
  )

  # Stat analysis
}
# stat_analysis_emg(window_method_data, output_directory_path)
# stat_analysis_emg_side(window_method_data, output_directory_path)
stat_analysis_cop(window_method_data, data_all_parameters, output_directory_path)
# stat_analysis_copemg(window_method_data, data_all_parameters, output_directory_path)
