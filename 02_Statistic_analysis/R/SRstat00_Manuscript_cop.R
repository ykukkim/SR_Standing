# Environment Setting ----
rm(list = ls()) # clearsthe environment - the one with the variables.

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
  # Path for macOS (Darwin is the underlying OS for macOS)
  setwd("/Users/yonkim/Desktop/SR/02_Statistic_analysis//R")
  sr_data_cop <- "/Users/yonkim/Desktop/SR/Result/Hilbert_TJ2sec"
  cop_path <- paste(sr_data_cop, "copParameters.xlsx", sep = "/")
  cop_spectra <- paste(sr_data_cop, "copspectra.xlsx", sep = "/")
  output_directory_path <- "/Users/yonkim/Desktop/SR/Result/Hilbert_TJ2sec/Stat_Results/CoP"

} else {
  stop("Unsupported OS")
}

source("./00_Functions/utilities_cop.R")

# Titles for the plots ----

ylabel_mean <- c(
  'Sway Area (mm)',
  expression("95% Ellipse Area (mm"^2*")",
  'Path Length (mm)')
  # expression(Ellipse~Area~Variability~(mm^2))
)

titles_param <- c(
  'Sway Area',
  expression("95% Ellipse Area"),
  'Path Length'
)

titles_save <- c(
  'Sway Area',
  'Ellipse Area',
  'Path Length'
)

ylabel_mean_APML<- c(
  'RMS Distance (mm)',
  'Mean Distance (mm)',
  'Mean Velocity (mm/s)',
  'Peak Velocity (mm/s)'
)

titles_save_APML <- c(
  'RMS Distance',
  'Mean Distance',
  'Mean Velocity',
  'Peak Velocity'
)

conditions_for_plot = c(expression("EC"[Hard]),
                        expression("EC"[Foam]),
                        expression("EC"[Foam+1*Hz]),
                        expression("EC"[Foam+1*Hz+WN])
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

# Processing Data for Parameters  ----
Conditions <- c('ECHard', 'ECFoam', 'ECFoam1Hz', 'ECFoam1HzWN')

# CoP Paramters ----
data_all_parameters  <- read.xlsx(cop_path)
data_all_parameters <- data_all_parameters %>%
  dplyr::select(-swayArea_rel, -rmsDist_r, -meanDist_r, -meanVel_r, -peakVel_r) %>%
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

# COP parameter stat analysis and boxplots ----
analyze_and_plot(data_all_parameters, output_directory_path, "copparameters",
                 "All",stimulation_order = Conditions)

# Create the box plots with jittered points for Parameter-----
box_plots <- plot_metric_manu(data_all_parameters, ylabel_mean,ylabel_mean_APML,titles_save,titles_param,titles_save_APML)


# Processing Data for freq  ----
sheet_names <- excel_sheets(cop_spectra)
data_all_spectra <- setNames(
  lapply(sheet_names, function(sheet) read_excel(cop_spectra, sheet = sheet)),
  sheet_names
)


# Cop and EMG stat for each window method ----
for (window_method in sheet_names){

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

  filtered_data_all <- process_spectra_data(temp_data)
  filtered_data_all$filtered_data <- filtered_data_all$filtered_data %>%
    do(remove_outliers(., "total_copspectra_x")) %>%
    do(remove_outliers(., "total_copspectra_y"))

  # perform stat analysis and boxplot
  analyze_and_plot(filtered_data_all$filtered_data, output_directory_path, "copspectra",
                   "All",stimulation_order = Conditions)

  # Create the box plots with jittered points for Frequency -----

  data_filtered_x <- filtered_data_all$filtered_data$total_copspectra_x
  data_filtered_y <- filtered_data_all$filtered_data$total_copspectra_y

  combined_plot_freq <- list()

  combined_plot_freq$x <- ggplot(filtered_data_all$filtered_data, aes(x = stim, y = total_copspectra_x, fill = stim)) +
    geom_boxplot(alpha = 0.6) +
    geom_jitter(aes(color = stim), width = 0.2, size = 1, alpha = 0.6) +
    labs(title = 'PSD: 0 - 1.5 Hz (AP)', x = "Condition", y = 'Power (dB)') +
    theme_minimal() +
    theme(legend.position = "none",
          plot.title = element_text(hjust=0.5),
          plot.margin = unit(c(0.02,0.02,0.02,0.02),"cm"))+
    scale_x_discrete(labels = conditions_for_plot) +
    scale_fill_manual(values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"), labels = conditions_for_plot) +
    scale_color_manual(values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"), labels = conditions_for_plot)

  combined_plot_freq$y <- ggplot(filtered_data_all$filtered_data, aes(x = stim, y = total_copspectra_y, fill = stim)) +
    geom_boxplot(alpha = 0.6) +
    geom_jitter(aes(color = stim), width = 0.2, size = 1, alpha = 0.6) +
    labs(title = 'PSD: 0 - 1.5 Hz (ML)', x = "Condition", y = 'Power (dB)') +
    theme_minimal() +
    theme(legend.position = "none",
          plot.title = element_text(hjust=0.5),
          plot.margin = unit(c(0.02,0.02,0.02,0.02),"cm"))+
    scale_x_discrete(labels = conditions_for_plot) +
    scale_fill_manual(values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"), labels = conditions_for_plot) +
    scale_color_manual(values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"), labels = conditions_for_plot)

  # Final polot ----
  combined_all_plots <- wrap_plots(box_plots$all$`Sway Area`, box_plots$all$`Ellipse Area`, box_plots$all$`Path Length`,
                                   box_plots$AP_Variables$`RMS Distance`,box_plots$AP_Variables$`Mean Velocity`,box_plots$AP_Variables$`Peak Velocity`,
                                    box_plots$ML_Variables$`RMS Distance`, box_plots$ML_Variables$`Mean Velocity`,box_plots$ML_Variables$`Peak Velocity`,
                                   combined_plot_freq$x,combined_plot_freq$y, ncol=3, nrow =4)


  for (i in 1:length(combined_all_plots)) {
      combined_all_plots[[i]] <- combined_all_plots[[i]] +
        theme(axis.title.x = element_blank(), axis.text.x = element_blank(), axis.ticks.x = element_blank())+scale_x_discrete(labels = conditions_for_plot)+    labs(title = NULL)  # Remove the title
  }

  ap_label <- textGrob("AP Direction", gp = gpar(fontsize = 10, fontface = "bold"))
  ml_label <- textGrob("ML Direction", gp = gpar(fontsize = 10, fontface = "bold"))

  # Combine the plots into the specified layout with row labels
  final_plot <- (wrap_plots(combined_all_plots[[1]], combined_all_plots[[2]], combined_all_plots[[3]], ncol = 3) /
                   ap_label /
                   wrap_plots(combined_all_plots[[10]], combined_all_plots[[4]], combined_all_plots[[5]], combined_all_plots[[6]], ncol = 4) /
                   ml_label /
                   wrap_plots(combined_all_plots[[11]], combined_all_plots[[7]], combined_all_plots[[8]], combined_all_plots[[9]], ncol = 4)) +
    plot_layout(heights = c(0.8, 0.05, 1, 0.05, 1), guides = 'collect') &
    theme(
      plot.margin = unit(c(0.02, 0.02, 0.02, 0.02), "cm"),
      legend.position = "bottom",
      legend.text = element_text(size = 10)  # Adjust the legend text size here
    )

  # Print the final plot
  print(final_plot)

  ggsave(
    filename = paste0(
      output_directory_path,
      "/",
      "boxplot_Manuscript2.svg"
    ),
    plot = final_plot,
    width = 8,
    height = 8,
  )

  # Define a list of the sub-list names you want to iterate over
  sub_list_names <- c("all", "ML_Variables", "AP_Variables")

  # Loop through each sub-list in box_plots
  for (sub_list_name in sub_list_names) {

    # Get the sub-list using the name
    sub_list <- box_plots[[sub_list_name]]

    # Loop through each plot in the sub-list
    for (i in seq_along(sub_list)) {
      plot_to_save <- sub_list[[i]]

      # Check if the object is indeed a ggplot
      if (is.ggplot(plot_to_save)) {
        # Construct the filename
        filename <- paste0(
          output_directory_path,
          "/",
          "boxplot_",
          sub_list_name,  # Include the sub-list name in the filename
          "_",
          names(sub_list)[i],  # Include the plot name
          "_Manuscript2.svg"
        )

        # Save the plot
        ggsave(
          filename = filename,
          plot = plot_to_save,
          width = 8,
          height = 10
        )
      } else {
        warning(paste("Element", i, "in sub-list", sub_list_name, "is not a ggplot object"))
      }
    }
  }
}
