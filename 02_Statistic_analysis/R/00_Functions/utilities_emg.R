# Function to identify and remove outliers ----
remove_outliers <- function(data, variable) {
  Q1 <- quantile(data[[variable]], 0.25, na.rm = TRUE)
  Q3 <- quantile(data[[variable]], 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  data <- data %>% filter(data[[variable]] >= (Q1 - 1.5 * IQR) &
                            data[[variable]] <= (Q3 + 1.5 * IQR))
  return(data)
}
# Function to extract nested data -----
extract_data <- function(data, muscle_pair_interested) {

  extracted_data <- list()
  extracted_data_variability<- list()

  for (window_method in names(data[["results"]])){

    extracted_data[[window_method]]<- data.frame()
    extracted_data_variability[[window_method]]<- data.frame()

    for (muscle in names(data[["results"]][[window_method]])) {
      # Check if the muscle pair is in the interested list and not the excluded one
      if (muscle %in% muscle_pair_interested) {

        for (condition in names(data[["results"]][[window_method]][[muscle]])) {
          for (band in names(data[["results"]][[window_method]][[muscle]][[condition]])) {

            # Get the list of participant IDs and coherence values
            coherence_list <- data[["results"]][[window_method]][[muscle]][[condition]][[band]]

            # Extract coherence values
            for (entry in coherence_list$mean) {
              participant_id <- entry[[1]]
              coherence_values <- entry[[2]]

              temp_data <- data.frame(
                muscle = rep(muscle, length(coherence_values)),
                condition = rep(condition, length(coherence_values)),
                band = rep(band, length(coherence_values)),
                participant = rep(participant_id, length(coherence_values)),
                coherence_value = coherence_values
              )

              extracted_data[[window_method]] <- rbind(extracted_data[[window_method]], temp_data)
            }

            # Extract variability values
            for (entry in coherence_list$variability) {
              participant_id <- entry[[1]]
              variability_values <- entry[[2]]

              temp_data_variability <- data.frame(
                muscle = rep(muscle, length(variability_values)),
                condition = rep(condition, length(variability_values)),
                band = rep(band, length(variability_values)),
                participant = rep(participant_id, length(variability_values)),
                variability_value = variability_values
              )

              extracted_data_variability[[window_method]] <- rbind(extracted_data_variability[[window_method]], temp_data_variability)
            }
          }
        }
      }
    }
  }
  return(
    list(extracted_data = extracted_data, variability_data = extracted_data_variability)
  )
}


# Store coherence values ----
store_coherence_values <- function(df, directory, window_method) {

  # Ensure the output directory path ends with a slash
  if (!grepl("/$", output_directory_path)) {
    output_directory_path <- paste0(output_directory_path, "/")
  }

  # Ensure the condition variable is correctly formatted
  df$condition <- as.factor(df$condition)

  # Initialize an Excel workbook
  wb <- createWorkbook()

  # Get unique muscles
  unique_muscles <- unique(df$muscle)

  for (muscle in unique_muscles) {
    # Filter data for the specific muscle
    subset_data <- df %>% filter(muscle == !!muscle)

    # Add a new worksheet for the muscle
    addWorksheet(wb, muscle)

    # Write the raw coherence values to the worksheet
    writeData(wb, sheet = muscle, subset_data)
  }

  # Create a filename
  filename <- paste0(directory, "/coherence_values_max_", window_method, ".xlsx")

  # Save the workbook
  saveWorkbook(wb, filename, overwrite = TRUE)
}
# Function to create and save boxplots with significant post-hoc comparisons using lmer ----
plotemgdata <- function(data_all,
                            output_directory_path,
                            file_prefix,
                            stimulation_order,
                            band_order,
                            window_method) {

  # Ensure the output directory path ends with a slash
  if (!grepl("/$", output_directory_path)) {
    output_directory_path <- paste0(output_directory_path, "/")
  }

  # Convert 'condition' to a factor with the specified order
  data_all$condition <- factor(data_all$condition, levels = stimulation_order)

  # Convert 'band' to a factor with the specified order
  data_all$band <- factor(data_all$band, levels = band_order)

  # Loop through each muscle in the dataframe
  for (muscle in unique(data_all$muscle)) {
    subset_data <- data_all %>% filter(muscle == !!muscle)

    # Fit the linear mixed-effects model
    model <- lmer(coherence_value ~ condition*band  + (1 | participant), data = subset_data)

    # Perform post-hoc pairwise comparisons using emmeans
    emmeans_res <- emmeans(model, pairwise ~ condition | band)
    comparisons <- summary(emmeans_res$contrasts)

    y_max <- max(subset_data$coherence_value, na.rm = TRUE)
    y_increment <- y_max * 0.03  # Adjust this value to change spacing between annotations

    # Filter significant comparisons and prepare for stat_pvalue_manual
    sig_comparisons <- comparisons %>%
      filter(p.value < 0.05) %>%
      separate(contrast,
               into = c("group1", "group2"),
               sep = " - ") %>%
      mutate(
        y.position = seq(y_max * 1.05, length.out = n(), by = y_increment),
        significance = case_when(
          p.value < 0.001 ~ "***",
          p.value < 0.01 ~ "**",
          p.value < 0.05 ~ "*",
          TRUE ~ ""
        )
      )

    # Create and save the grouped bar plot with significant annotations using stat_pvalue_manual
    p <- ggplot(subset_data,
                aes(x = condition, y = coherence_value, fill = band)) +
      geom_bar(stat = "identity", position = position_dodge()) +
      labs(title = paste("Bar Plot of", muscle),
           y = "Coherence Value",
           x = "Bands") +
      theme_minimal() +
      coord_cartesian(ylim = c(0, y_max * 1.2))  # Adjust y-axis range


    # Only add stat_pvalue_manual if there are significant comparisons
    if (nrow(sig_comparisons) > 0) {
      p <- p + stat_pvalue_manual(
        data = sig_comparisons,
        label = "significance",
        y.position = "y.position",
        tip.length = 0.01
      )
    }

    ggsave(
      filename = paste0(
        output_directory_path,
        "/",
        "barplot_",
        file_prefix,
        "_",
        muscle,
        "_",
        window_method,
        ".png"
      ),
      plot = p,
      device = "png",
      width = 10,
      height = 6,
      dpi = 300
    )
  }
}
