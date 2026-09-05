# Coherence Analysis Study
# This script is designed to analyze coherence values across different conditions, sessions, and participants.
# It includes functions for data processing, statistical analysis, and visualization.

# Frequency Bands:
# Delta: 0 - 4 Hz
# Theta: 4 - 8 Hz
# Alpha: 8 - 12 Hz
# Beta: 12 - 30 Hz
# Gamma: 30 - 61 Hz

# Conditions:
# EC-Hard: Eyes closed on a hard surface
# EC-Foam: Eyes closed on a foam surface
# EC-Foam+1HZ: Eyes closed on a foam surface with 1Hz stimulation
# EC-Foam+1HZ+WN: Eyes closed on a foam surface with 1Hz stimulation and white noise

# Store raw coherence values
# This function stores raw coherence values into an Excel workbook.
# store_raw_coherence_values
# - Inputs: df (data frame), directory (string)

# Function to create and save boxplots with significant post-hoc comparisons using lmer
# This function creates and saves boxplots, highlighting significant post-hoc comparisons.
# plotboxplotdata
# - Inputs: data_all (data frame), output_directory_path (string), file_prefix (string), stimulation_order (vector), band_order (vector)

# Statistical analysis loop through each muscle and band
# This function performs statistical analysis and stores results in an Excel workbook.
# stat_analysis
# - Inputs: df (data frame), variable (string), directory (string)

# Function to create faceted box plots for all bands of a single muscle pair across all conditions without outliers
# This function creates faceted box plots for a single muscle pair across all conditions.
# create_faceted_boxplots
# - Inputs: df (data frame), muscle_pair (string)

# Extract p-values from the model
# This function extracts p-values from pairwise comparisons for each muscle and band.
# extract_p_values
# - Inputs: df (data frame)
# - Outputs: data frame with p-values
# Clear ----
rm(list = ls()) # clearsthe environment - the one with the variables.

# Libraries ----
#install.packages("pacman")
pacman::p_load(
  readxl,
  openxlsx,
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
  lme4
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
  output_directory_path <- "/Users/yonkim/Desktop/SR/Result/Hilbert_TJ2sec/Stat_Results/EMG"
} else {
  stop("Unsupported OS")
}

source("./00_Functions/utilities_emg.R")

Conditions <- c('ECHard', 'ECFoam', 'ECFoam1Hz', 'ECFoam1HzWN')
band_order <- c("Delta", "Theta", "Alpha", "Beta", "Gamma")
muscle_pair_interested <- c("SOL_L_SOL_R","SOL_L_TAN_L","SOL_L_GAL_L","TAN_L_GAL_L","SOL_R_TAN_R","SOL_R_GAL_R","TAN_R_GAL_R","TAN_L_TAN_R","GAL_L_GAL_R")
conditions_for_plot <- c(expression("EC"[Hard]),
                         expression("EC"[Foam]),
                         expression("EC"[Foam+1*Hz]),
                         expression("EC"[Foam+1*Hz+WN])
)

# Read Data and process Data ----

interemgcoherence <- read.mat(paste0(sr_data, '/', 'coherence_band_results_mean.mat'))
results <- extract_data(interemgcoherence,muscle_pair_interested)

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


for (window_method in names(results[["extracted_data"]])){


  df <- results$extracted_data[[window_method]] %>%
    group_by(muscle, band, condition) %>%
    do(remove_outliers(., "coherence_value")) %>%
    filter(condition %in% Conditions)

  df_variability <- results$variability_data[[window_method]] %>%
    group_by(muscle, band, condition) %>%
    do(remove_outliers(., "variability_value")) %>%
    filter(condition %in% Conditions)

  df <- df[, c(4, 1, 2,3,5)]
  df_variability <- df_variability[, c(4, 1, 2,3,5)]

  df <- df %>%
    mutate(
      band = case_when(
        band == "delta" ~ "Delta",
        band == "theta" ~ "Theta",
        band == "alpha" ~ "Alpha",
        band == "beta" ~ "Beta",
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
        band == "beta" ~ "Beta",
        band == "gamma" ~ "Gamma",
        TRUE ~ band  # Keeps original value if none of the above conditions are met
      )
    )

  # Store raw coherence values ----
  store_coherence_values(df, output_directory_path, window_method)

  # Box plots with sig, but can plot without sig just comment the analysis out -----
  plotemgdata(df, output_directory_path, "All",stimulation_order = Conditions, band_order,window_method)

  # Set the levels for factors
  df$muscle <- factor(df$muscle, levels = muscle_pair_interested)
  df$condition <- factor(df$condition, levels = Conditions)
  df$band <- factor(df$band, levels = band_order)

  # Create the plot
  plot <- ggplot(df, aes(x = band, y = coherence_value, fill = condition)) +
    geom_bar(stat = "identity", position = "dodge") +
    facet_wrap(~ muscle, ncol = 3) +  # Arrange plots with the same y-axis
    theme_minimal() +
    theme(
      legend.position = "bottom",
      legend.text = element_text(size = 10)  # Adjust the legend text size
    ) +
    labs(x = "", y = "Coherence Value", fill = "Condition") +
    scale_x_discrete(labels = levels(df$band)) +  # Apply custom x-axis labels
    scale_fill_manual(
      values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"),  # Custom colours
      labels = conditions_for_plot  # Use expressions for legend labels
    )

  # Display the plot
  print(plot)

  ggsave(
    filename = paste0(
      output_directory_path,
      '/',
      "barplot_EMGManuscript_",window_method,".svg"
    ),
    plot = plot,
    width = 8,
    height = 8
  )
}
