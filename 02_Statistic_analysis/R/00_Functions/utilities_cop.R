# Function to identify and remove outliers ----
remove_outliers <- function(data, variable) {
  Q1 <- quantile(data[[variable]], 0.25, na.rm = TRUE)
  Q3 <- quantile(data[[variable]], 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  data <- data %>% filter(data[[variable]] >= (Q1 - 1.5 * IQR) &
                            data[[variable]] <= (Q3 + 1.5 * IQR))
  return(data)
}

# Perform stat analysis and boxplot ----
analyze_and_plot <- function(data_all,
                             output_directory_path,
                             variable_prefix,
                             file_prefix,
                             stimulation_order) {

  # Ensure output directory path ends with a slash
  if (!grepl("/$", output_directory_path)) {
    output_directory_path <- paste0(output_directory_path, "/")
  }

  # Set stimulation order as factor levels
  data_all$stim <- factor(data_all$stim, levels = stimulation_order)

  # Identify variables for boxplot analysis
  variables <- setdiff(names(data_all), c("participant", "session","trial","stim"))

  # Initialize workbook for saving post-hoc results
  wb <- createWorkbook()

  # Loop through each variable for analysis and plotting
  for (var in variables) {
    # Fit the mixed-effects model
    model <- lmer(as.formula(paste(var, "~ stim + (1 | participant)")), data = data_all)

    # Post-hoc analysis
    posthoc_res <- emmeans(model, pairwise ~ stim, adjust = "bonferroni")
    contrast_df <- as.data.frame(posthoc_res$contrasts)

    # Homogeneity of Variance Test (Levene's Test)
    data_all$residuals <- residuals(model)
    levene_res <- car::leveneTest(residuals ~ stim, data = data_all)

    # Normality Test (Shapiro-Wilk)
    shapiro_res <- shapiro.test(data_all$residuals)

    # Collect test results in a separate data frame
    test_results <- data.frame(
      Test = c("Levene's Test P-Value", "Shapiro-Wilk Test P-Value"),
      P_Value = c(levene_res$`Pr(>F)`[1], shapiro_res$p.value)
    )

    # Add a worksheet for each variable
    addWorksheet(wb, sheetName = var)

    # Write contrast results
    writeData(wb, sheet = var, x = contrast_df, startRow = 1, colNames = TRUE)

    # Write test results starting below the contrast data
    writeData(wb, sheet = var, x = test_results, startRow = nrow(contrast_df) + 3, colNames = TRUE)

    # Q-Q Plot of Residuals for Normality Check
    qq_plot <- ggplot(data_all, aes(sample = residuals)) +
      stat_qq() +
      stat_qq_line() +
      ggtitle(paste("Q-Q Plot of Residuals -", var))

    ggsave(
      filename = paste0(output_directory_path, "qqplot_", file_prefix, "_", var, ".png"),
      plot = qq_plot,
      width = 7,
      height = 5,
      dpi = 300
    )

    # Homogeneity Plot (Absolute Residuals vs. Fitted Values)
    homogeneity_plot <- ggplot(data_all, aes(x = fitted(model), y = abs(residuals))) +
      geom_point() +
      labs(title = paste("Absolute Residuals vs. Fitted Values -", var), x = "Fitted values", y = "Absolute residuals")

    ggsave(
      filename = paste0(output_directory_path, "homogeneity_", file_prefix, "_", var, ".png"),
      plot = homogeneity_plot,
      width = 7,
      height = 5,
      dpi = 300
    )

    # Identify Significant Comparisons for Boxplot Annotation
    sig_comparisons <- list()

    for (j in seq_len(nrow(contrast_df))) {
      if (contrast_df$p.value[j] < 0.05) {
        sig_comparisons <- append(sig_comparisons, list(unlist(strsplit(contrast_df$contrast[j], " - "))))
      }
    }

    # Create and Save Boxplot with Significance Annotations
    boxplot <- ggplot(data_all, aes(x = stim, y = !!sym(var))) +
      geom_boxplot() +
      labs(title = paste("Boxplot of", var), y = var, x = "Conditions") +
      stat_compare_means(
        comparisons = sig_comparisons,
        map_signif_level = TRUE,
        method = "t.test",
        label = "p.signif"
      )

    ggsave(
      filename = paste0(output_directory_path, "boxplot_", file_prefix, "_", var, ".png"),
      plot = boxplot,
      width = 7,
      height = 5,
      dpi = 300
    )

    # Summary of Results for Printing
    summary_results <- list(
      Variable = var,
      Levenes_Test_P_Value = levene_res$`Pr(>F)`[1],
      Shapiro_Test_P_Value = shapiro_res$p.value,
      Posthoc_Contrasts = contrast_df$contrast,
      Posthoc_P_Values = contrast_df$p.value
    )

    print(summary_results)  # Optional: Print to console if needed
  }

  # Save the workbook to the specified directory
  saveWorkbook(wb, file = paste0(output_directory_path, variable_prefix,"_posthoc_results.xlsx"), overwrite = TRUE)

  message("Results saved to: ", paste0(output_directory_path, variable_prefix, "__posthoc_results.xlsx"))
}

# Box plot with jitter ----
plot_metric_manu <- function(data, ylabel,ylabel_APML,titles_save,titles_param,titles_save_APML, has_metric = TRUE) {
  plots <- list()
  numeric_vars <- names(data)[sapply(data, is.numeric)]

  # Separate variables for combined plotting
  ap_vars <- numeric_vars[grepl("_x", numeric_vars)]
  ml_vars <- numeric_vars[grepl("_y", numeric_vars)]
  other_vars <- numeric_vars[!numeric_vars %in% c(ap_vars, ml_vars)]

  # Plot AP and ML variables in one figure
  combined_plot <- function(vars, data, y_label, title_names, titles_param,title_suffix) {
    combined_plot_list <- list()
    for (i in seq_along(vars)) {
      variable_name <- vars[i]

      data_filtered <- remove_outliers(data, variable_name)
      data_filtered$stim <- factor(data_filtered$stim, levels = Conditions)

      p <- ggplot(data_filtered, aes(x = stim, y = !!sym(variable_name), fill = stim)) +
        geom_boxplot(alpha = 0.6) +
        geom_jitter(aes(color = stim), width = 0.2, size = 1, alpha = 0.6) +
        labs(title = paste(title_names[i], title_suffix), x = "Condition", y = y_label[[i]]) +
        theme_minimal() +
        theme(legend.position = "none",
              plot.title = element_text(hjust=0.5),
              plot.margin = unit(c(0.02,0.02,0.02,0.02),"cm"))+
        scale_x_discrete(labels = conditions_for_plot) +
        scale_fill_manual(values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"), labels = conditions_for_plot) +
        scale_color_manual(values = c("#F8766D", "#00BA38", "#619CFF", "#F564E3"), labels = conditions_for_plot)

      combined_plot_list[[title_names[i]]] <- p
    }

    return(combined_plot_list)
  }

  if (length(other_vars) > 0) {
    plots[["all"]] <- combined_plot(other_vars, data, ylabel,titles_save,titles_param,title_suffix = "")
  }

  if (length(ap_vars) > 0) {
    plots[["AP_Variables"]] <- combined_plot(ap_vars, data, ylabel_APML, titles_save_APML, title_suffix = "(AP)")
  }

  if (length(ml_vars) > 0) {
    plots[["ML_Variables"]] <- combined_plot(ml_vars, data, ylabel_APML,titles_save_APML, title_suffix = "(ML)")
  }
  return(plots)
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
    group_by(participant, stim) %>%
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
