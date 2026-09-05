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
            for (entry in coherence_list$coherencevalue) {
              participant_id <- entry[[1]]
              trial<- entry[[2]]
              coherence_values <- entry[[3]]

              temp_data <- data.frame(
                participant = rep(participant_id, length(coherence_values)),
                condition = rep(condition, length(coherence_values)),
                trial =  rep(trial, length(coherence_values)),
                band = rep(band, length(coherence_values)),
                muscle = rep(muscle, length(coherence_values)),
                coherence_value = coherence_values
              )

              extracted_data[[window_method]] <- rbind(extracted_data[[window_method]], temp_data)
            }

            # Extract variability values
            for (entry in coherence_list$variability) {
              participant_id <- entry[[1]]
              variability_values <- entry[[2]]

              temp_data_variability <- data.frame(
                participant = rep(participant_id, length(variability_values)),
                condition = rep(condition, length(variability_values)),
                band = rep(band, length(variability_values)),
                muscle = rep(muscle, length(variability_values)),
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


# Process CoP Spectra ----
process_spectra_data <- function(data) {

  data_spectra_xy <- data %>%
    dplyr::select(participant, session, trial, stim, bin, frequencies,copspectra_x,copspectra_y) %>%  # Select specific columns
    filter(frequencies <= 1.5) %>%  # Filter rows where frequency is <= 1.5
    mutate(frequencies = as.numeric(frequencies))  # Ensure 'frequency' is numeric

  # Summing values for each participant and trial
  summed_data <- data_spectra_xy%>%
    group_by(participant, session,trial, stim) %>%
    summarise(
      total_copspectra_x = sum(copspectra_x, na.rm = TRUE),
      total_copspectra_y = sum(copspectra_y, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    arrange(stim)

  std_dev_across_conditions <- summed_data %>%
    group_by(stim) %>%
    summarise(
      Mean_x = mean(total_copspectra_x, na.rm = TRUE),
      Std_x = sd(total_copspectra_x, na.rm = TRUE),
      Mean_y = mean(total_copspectra_y, na.rm = TRUE),
      Std_y = sd(total_copspectra_y, na.rm = TRUE),
      .groups = 'drop'
    )

  std_dev_same_session <- summed_data %>%
    group_by(participant, session) %>%
    summarise(
      Mean_x = mean(total_copspectra_x, na.rm = TRUE),
      Std_x = sd(total_copspectra_x, na.rm = TRUE),
      Mean_y = mean(total_copspectra_y, na.rm = TRUE),
      Std_y = sd(total_copspectra_y, na.rm = TRUE),
      .groups = 'drop'
    )

  # Variability
  Variability <- std_dev_same_session %>%
    group_by(session) %>%
    summarise(Variability_x = mean(Std_x, na.rm = TRUE),
              Variability_y = mean(Std_y, na.rm = TRUE),
              .groups = 'drop')

  # Summing values for each participant and trial
  summed_data <- data_spectra_xy%>%
    group_by(participant, trial,stim) %>%
    summarise(
      total_copspectra_x = sum(copspectra_x, na.rm = TRUE),
      total_copspectra_y = sum(copspectra_y, na.rm = TRUE)
    ) %>%
    ungroup() %>%
    arrange(stim)


  return(
    list(
      filtered_data = summed_data,
      std_dev_across_conditions = std_dev_across_conditions,
      std_dev_same_session = std_dev_same_session,
      Variability = Variability
    )
  ) # Return the aggregated FFT sums
}


# Stat analysis of association between Coherence for side difference vs Conditions only  ----
stat_analysis_emg_side <- function(window_method_data, directory) {

  # Define the output file path
  filename <- file.path(directory, paste0("stat_analysis_results_emg_side_", Sys.Date(), ".xlsx"))

  # Create workbook and initialize the Coherence worksheet
  wb <- createWorkbook()
  addWorksheet(wb, "Coherence")
  start_row <- 1

  # Define the specific bilateral muscle pairs for comparison
  bilateral_pairs <- list(
    "SOL_L_GAL_L" = "SOL_R_GAL_R",
    "SOL_L_TAN_L" = "SOL_R_TAN_R",
    "TAN_L_GAL_L" = "TAN_R_GAL_R"
  )

  # Loop through each bilateral muscle pair
  for (pair_left in names(bilateral_pairs)) {
    pair_right <- bilateral_pairs[[pair_left]]

    # Loop through each unique band within the muscle pairs
    unique_bands <- unique(unlist(lapply(window_method_data, function(data) {
      df <- data$df
      df$band[(df$muscle == pair_left | df$muscle == pair_right)]
    })))

    for (band in unique_bands) {

      # Initialize consolidated results data frame for coherence
      consolidated_results_coh <- data.frame(
        muscle_pair =  character(),
        band =  character(),
        condition = character(),
        contrast = character(),
        stringsAsFactors = FALSE
      )

      # Loop through each window method to gather data for coherence model
      for (window_method in names(window_method_data)) {

        # Access data for the current window method
        df <- window_method_data[[window_method]]$df

        # Filter data for the current muscle pair and band
        subset_data <- df %>%
          filter((muscle == pair_left | muscle == pair_right) & band ==!! band) %>%
          mutate(side = ifelse(muscle == pair_left, "Left", "Right"))

        subset_data$trial <- as.numeric(gsub("T", "", as.character(subset_data$trial)))

        try({
          # Fit the model for coherence with condition and side interactions
          formula <- as.formula("coherence_value ~ side * condition + (1 | participant)")
          model <- lmer(formula, data = subset_data)

          # Conduct post-hoc tests for side differences within each condition
          posthoc_res <- emmeans(model, pairwise ~ side | condition, adjust = "bonferroni")
          contrasts <- summary(posthoc_res$contrasts)

          # Check if contrasts are available
          if (nrow(contrasts) == 0) {
            message(paste("No contrasts found for", pair_left, "vs", pair_right, "in band", band))
            next
          }

          # Temporary data frame for p-values for the current window method
          temp_results_coh <- data.frame(
            muscle = paste(pair_left, "vs", pair_right),
            band = band,
            condition = contrasts$condition,
            contrast = contrasts$contrast,
            stringsAsFactors = FALSE
          )
          temp_results_coh[[paste0("p_value_", window_method)]] <- contrasts$p.value

          # Consolidate results side-by-side for each window method
          if (nrow(consolidated_results_coh) == 0) {
            consolidated_results_coh <- temp_results_coh
          } else {
            consolidated_results_coh <- full_join(consolidated_results_coh, temp_results_coh,
                                                  by = c("muscle", "band", "condition", "contrast"))
          }

        }, silent = TRUE)  # Continue if model fitting fails
      }

      # Write the consolidated results to the workbook
      writeData(wb, sheet = "Coherence", consolidated_results_coh, startRow = start_row, withFilter = TRUE)
      start_row <- start_row + nrow(consolidated_results_coh) + 3  # Update start row for the next band
    }
  }

  # Save the workbook after processing all data
  saveWorkbook(wb, filename, overwrite = TRUE)
  message(paste("Workbook saved as", filename))
}

# Stat analysis of association between Coherence vs Conditions only ----
stat_analysis_emg <- function(window_method_data, directory) {

  # Define the output file path
  filename <- file.path(directory, paste0("stat_analysis_results_emg_", Sys.Date(), ".xlsx"))

  # Create workbook
  wb <- createWorkbook()
  addWorksheet(wb, "Coherence")
  start_row <- 1

  # Loop through each muscle to create a sheet per muscle
  for (muscle in unique(unlist(lapply(window_method_data, function(data) unique(data$df$muscle))))) {

    # Initialize starting row for each muscle sheet
    for (band in unique(unlist(lapply(window_method_data, function(data) unique(data$df$band[data$df$muscle == muscle]))))) {

      # Initialize consolidated results
      consolidated_results_coh <- data.frame(
        muscle = character(),
        band = character(),
        contrast = character(),
        stringsAsFactors = FALSE
      )

      # Loop through each window_method and fit the model, extract p-values
      for (window_method in names(window_method_data)) {

        # Access data for the current window method
        filtered_data_all <- window_method_data[[window_method]]$df

        # Filter data for the current muscle-band combination
        subset_data <- filtered_data_all %>% filter(muscle == !!muscle, band == !!band)
        subset_data$trial <- as.numeric(gsub("T", "", as.character(subset_data$trial)))

        # Fit model for coherence and extract p-values
        model_coh <- lmer(coherence_value ~ condition + (1 | participant) + (1 | trial), data = subset_data)
        posthoc_res_coh <- emmeans(model_coh, pairwise ~ condition)

        # Create a temporary data frame for p-values of the current window method
        temp_results_coh <- data.frame(
          muscle = muscle,
          band = band,
          contrast = summary(posthoc_res_coh)$contrasts$contrast,
          stringsAsFactors = FALSE
        )
        temp_results_coh[[paste0("p_value_", window_method)]] <- summary(posthoc_res_coh)$contrasts$p.value

        # Append results for the current window method to consolidated results
        if (nrow(consolidated_results_coh) == 0) {
          # Start with the first window's results
          consolidated_results_coh <- temp_results_coh
        } else {
          # Add new columns from additional window methods
          consolidated_results_coh <- full_join(consolidated_results_coh, temp_results_coh, by = c("muscle", "band", "contrast"))
        }
      }

      # Write header text and consolidated results to the workbook
      writeData(wb, sheet = "Coherence", consolidated_results_coh, startRow = start_row, withFilter = TRUE)
      start_row <- start_row + nrow(consolidated_results_coh) + 3
    }
  }

  # Save the workbook after processing all data
  saveWorkbook(wb, filename, overwrite = TRUE)
}
# Stat analysis of association between CoP vs Conditions only ----
stat_analysis_cop <- function(window_method_data, cop_data, directory) {

  # Define the output file path
  filename <- file.path(paste0(directory, "stat_analysis_results_cop_", Sys.Date(), ".xlsx"))

  # Create workbook
  wb <- createWorkbook()

  # Define sheet names for primary models and cop_data variables
  primary_sheets <- c("Spectra X", "Spectra Y")
  cop_data_sheets <- setdiff(names(cop_data), c("participant", "trial", "stim"))

  # Add sheets for primary models
  addWorksheet(wb, "Spectra X")
  addWorksheet(wb, "Spectra Y")

  # Add sheets for each cop_data variable
  for (var in cop_data_sheets) {
    addWorksheet(wb, var)
  }

  # Initialize starting rows for each sheet
  start_rows <- list("Spectra X" = 1, "Spectra Y" = 1)
  for (var in cop_data_sheets) {
    start_rows[[var]] <- 1
  }

  # Process primary models ----
  # Initialize consolidated results for primary models
  consolidated_results_x <- data.frame(contrast = character(), stringsAsFactors = FALSE)
  consolidated_results_y <- consolidated_results_x

  # Initialize consolidated results outside the loop if not already done
  consolidated_results_x <- data.frame(contrast = character(), stringsAsFactors = FALSE)
  consolidated_results_y <- data.frame(contrast = character(), stringsAsFactors = FALSE)

  # Loop through each window_method for primary models
  for (window_method in names(window_method_data)) {
    data <- window_method_data[[window_method]]
    filtered_data_all <- data$filtered_data_all

    # Merge data without filtering by muscle
    merged_df <- filtered_data_all$filtered_data %>%
      left_join(cop_data, by = c("participant", "trial" = "trial", "stim" = "stim"))
    merged_df$trial <- as.numeric(gsub("T", "", as.character(merged_df$trial)))

    # Fit models and collect post-hoc results
    model_x <- lmer(total_copspectra_x ~ stim + (1 | participant) + (1 | trial), data = merged_df)
    model_y <- lmer(total_copspectra_y ~ stim + (1 | participant) + (1 | trial), data = merged_df)

    # Conduct post-hoc pairwise comparisons for stim in each model
    posthoc_res_x <- emmeans(model_x, pairwise ~ stim)
    posthoc_res_y <- emmeans(model_y, pairwise ~ stim)

    # Temporary data frames for current window_method p_values
    temp_results_x <- data.frame(contrast = summary(posthoc_res_x)$contrasts$contrast, stringsAsFactors = FALSE)
    temp_results_x[[paste0("p_value_", window_method)]] <- summary(posthoc_res_x)$contrasts$p.value

    temp_results_y <- data.frame(contrast = summary(posthoc_res_y)$contrasts$contrast, stringsAsFactors = FALSE)
    temp_results_y[[paste0("p_value_", window_method)]] <- summary(posthoc_res_y)$contrasts$p.value

    # Append results for each model
    consolidated_results_x <- full_join(consolidated_results_x, temp_results_x, by = "contrast")
    consolidated_results_y <- full_join(consolidated_results_y, temp_results_y, by = "contrast")
  }

  # Write results for each primary model to the workbook
  writeData(wb, "Spectra X", consolidated_results_x, startRow = start_rows[["Spectra X"]], withFilter = TRUE)
  start_rows[["Spectra X"]] <- start_rows[["Spectra X"]] + nrow(consolidated_results_x) + 3

  writeData(wb, "Spectra Y", consolidated_results_y, startRow = start_rows[["Spectra Y"]], withFilter = TRUE)
  start_rows[["Spectra Y"]] <- start_rows[["Spectra Y"]] + nrow(consolidated_results_y) + 3

  # Separate loop for each cop_data variable across all window_methods ----
  for (var in cop_data_sheets) {
    consolidated_cop_data <- data.frame(contrast = character(), stringsAsFactors = FALSE)

    # Process each window_method for the current cop_data variable
    for (window_method in names(window_method_data)) {
      data <- window_method_data[[window_method]]
      filtered_data_all <- data$filtered_data_all

      merged_df <- filtered_data_all$filtered_data %>%
        left_join(cop_data, by = c("participant", "trial" = "trial", "stim" = "stim"))
      merged_df$trial <- as.numeric(gsub("T", "", as.character(merged_df$trial)))

      # Fit the model for the cop_data variable and extract p_values
      model_cop <- lmer(as.formula(paste(var, "~ stim + (1 | participant) + (1 | trial)")), data = merged_df)
      posthoc_res_cop <- emmeans(model_cop, pairwise ~ stim)

      # Temporary results for the current window_method
      temp_results_cop <- data.frame(
        contrast = summary(posthoc_res_cop)$contrasts$contrast,
        stringsAsFactors = FALSE
      )
      temp_results_cop[[paste0("p_value_", window_method)]] <- summary(posthoc_res_cop)$contrasts$p.value

      # Append to consolidated results for this cop_data variable
      consolidated_cop_data <- full_join(consolidated_cop_data, temp_results_cop, by = "contrast")
    }

    # Write consolidated cop_data results to the workbook
    writeData(wb, var, consolidated_cop_data, startRow = start_rows[[var]], withFilter = TRUE)
    start_rows[[var]] <- start_rows[[var]] + nrow(consolidated_cop_data) + 3
  }

  # Save the workbook after processing all data
  saveWorkbook(wb, filename, overwrite = TRUE)
}

# Stat analysis of association between Cop vs Coherence * Conditions ----
stat_analysis_copemg <- function(window_method_data, cop_data, directory) {

  # Define the output file path
  filename <- file.path(paste0(directory, "stat_analysis_results_all_", Sys.Date(), ".xlsx"))

  # Create workbook
  wb <- createWorkbook()

  # Define sheet names for primary models and cop_data variables
  primary_sheets <- c("Spectra X", "Spectra Y")
  cop_data_sheets <- setdiff(names(cop_data), c("participant", "trial", "stim"))

  # Add sheets for primary models
  addWorksheet(wb, "Spectra X")
  addWorksheet(wb, "Spectra Y")

  # Add sheets for each cop_data variable
  for (var in cop_data_sheets) {
    addWorksheet(wb, var)
  }

  # Initialize starting rows for each sheet
  start_rows <- list("Spectra X" = 1, "Spectra Y" = 1)
  for (var in cop_data_sheets) {
    start_rows[[var]] <- 1
  }

  # Process primary models ----
  for (muscle in unique(unlist(lapply(window_method_data, function(data) unique(data$df$muscle))))) {
    for (band in unique(unlist(lapply(window_method_data, function(data) unique(data$df$band[data$df$muscle == muscle]))))) {

      # Initialize consolidated results for primary models
      consolidated_results_x <- data.frame(muscle = character(), band = character(),
                                           contrast = character(), stringsAsFactors = FALSE)
      consolidated_results_y <- consolidated_results_x

      # Loop through each window_method for primary models
      for (window_method in names(window_method_data)) {
        data <- window_method_data[[window_method]]
        filtered_data_all <- data$filtered_data_all

        # Filter and merge data for the current muscle-band combination
        subset_data <- data$df %>% filter(muscle == !!muscle, band == !!band)
        merged_df <- subset_data %>%
          left_join(filtered_data_all$filtered_data, by = c("participant", "trial" = "trial", "condition" = "stim")) %>%
          left_join(cop_data, by = c("participant", "trial" = "trial", "condition" = "stim"))
        merged_df$trial <- as.numeric(gsub("T", "", as.character(merged_df$trial)))

        # Fit models and collect post-hoc results
        model_x <- lmer(total_copspectra_x ~ coherence_value * condition + (1 | participant) + (1 | trial), data = merged_df)
        model_y <- lmer(total_copspectra_y ~ coherence_value * condition + (1 | participant) + (1 | trial), data = merged_df)

        # Gather p_values for each model
        posthoc_res_x <- emtrends(model_x, ~ condition, var = "coherence_value")
        posthoc_res_y <- emtrends(model_y, ~ condition, var = "coherence_value")

        # Temporary data frames for current window_method p_values
        temp_results_x <- data.frame(muscle = muscle, band = band, contrast = summary(contrast(posthoc_res_x, "pairwise"))$contrast, stringsAsFactors = FALSE)
        temp_results_x[[paste0("p_value_", window_method)]] <- summary(contrast(posthoc_res_x, "pairwise"))$p.value

        temp_results_y <- data.frame(muscle = muscle, band = band, contrast = summary(contrast(posthoc_res_y, "pairwise"))$contrast, stringsAsFactors = FALSE)
        temp_results_y[[paste0("p_value_", window_method)]] <- summary(contrast(posthoc_res_y, "pairwise"))$p.value

        # Append results for each model
        consolidated_results_x <- full_join(consolidated_results_x, temp_results_x, by = c("muscle", "band", "contrast"))
        consolidated_results_y <- full_join(consolidated_results_y, temp_results_y, by = c("muscle", "band", "contrast"))
      }

      # Write results for each primary model to the workbook
      writeData(wb, "Spectra X", consolidated_results_x, startRow = start_rows[["Spectra X"]], withFilter = TRUE)
      start_rows[["Spectra X"]] <- start_rows[["Spectra X"]] + nrow(consolidated_results_x) + 3

      writeData(wb, "Spectra Y", consolidated_results_y, startRow = start_rows[["Spectra Y"]], withFilter = TRUE)
      start_rows[["Spectra Y"]] <- start_rows[["Spectra Y"]] + nrow(consolidated_results_y) + 3
    }
  }

  # Separate loop for each cop_data variable across all window_methods ----
  for (var in cop_data_sheets) {

    # Filter and merge data for the current muscle-band combination
    for (muscle in unique(unlist(lapply(window_method_data, function(data) unique(data$df$muscle))))) {
      for (band in unique(unlist(lapply(window_method_data, function(data) unique(data$df$band[data$df$muscle == muscle]))))) {

        consolidated_cop_data <- data.frame(muscle = character(), band = character(), contrast = character(), stringsAsFactors = FALSE)

        # Process each window_method for the current cop_data variable
        for (window_method in names(window_method_data)) {
          data <- window_method_data[[window_method]]

          subset_data <- data$df %>% filter(muscle == !!muscle, band == !!band)
          merged_df <- subset_data %>%
            left_join(data$filtered_data_all$filtered_data, by = c("participant", "trial" = "trial", "condition" = "stim")) %>%
            left_join(cop_data, by = c("participant", "trial" = "trial", "condition" = "stim"))
          merged_df$trial <- as.numeric(gsub("T", "", as.character(merged_df$trial)))

          # Fit the model for the cop_data variable and extract p_values
          model_cop <- lmer(as.formula(paste(var, "~ coherence_value * condition + (1 | participant) + (1 | trial)")), data = merged_df)
          posthoc_res_cop <- emtrends(model_cop, ~ condition, var = "coherence_value")
          contrast_res_cop <- contrast(posthoc_res_cop, "pairwise")

          # Temporary results for the current window_method
          temp_results_cop <- data.frame(
            muscle = muscle,
            band = band,
            contrast = summary(contrast_res_cop)$contrast,
            stringsAsFactors = FALSE
          )
          temp_results_cop[[paste0("p_value_", window_method)]] <- summary(contrast_res_cop)$p.value

          # Append to consolidated results for this cop_data variable
          consolidated_cop_data <- full_join(consolidated_cop_data, temp_results_cop, by = c("muscle", "band", "contrast"))
        }
        # Write consolidated cop_data results to the workbook
        writeData(wb, var, consolidated_cop_data, startRow = start_rows[[var]], withFilter = TRUE)
        start_rows[[var]] <- start_rows[[var]] + nrow(consolidated_cop_data) + 3
      }
    }
  }

  # Save the workbook after processing all data
  saveWorkbook(wb, filename, overwrite = TRUE)
}
