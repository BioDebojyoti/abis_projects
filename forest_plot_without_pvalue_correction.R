# forest plot without p-value corrections
forest_from_table <- function(df2plot,
                              title = "early nutrition year 1",
                              imputed_output = FALSE){
  
  print("Load appropriate parameters corresponding to questionnaire year!!")
  
  xlim_max = round(max(df2plot$estimate, na.rm = TRUE),0) + 2
  
  names(df2plot) <- c("feature", "no", "yes", "OR", "p", "lower", "upper")
  
  df2plot$OR <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$OR[[i]])) as.numeric(df2plot$OR[[i]]) else as.numeric(NA))
  df2plot$p <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$p[[i]])) as.numeric(df2plot$p[[i]]) else as.numeric(NA))
  
  df2plot <- df2plot %>% dplyr::select(feature, no, yes,OR, lower,upper,p)
  
  subgroup_patterns <- to_vec(for (sgp in unique(unlist(all_parameters$labels))) gsub("_"," ",sgp))
  
  df2plot$feature <- ifelse(df2plot$feature %in% subgroup_patterns,
                            paste0("    ",df2plot$feature), 
                            df2plot$feature
  )
  
  df2plot$no <- ifelse(is.na(df2plot$no), "", df2plot$no)
  df2plot$yes <- ifelse(is.na(df2plot$yes), "", df2plot$yes)
  df2plot$p <- ifelse(is.na(df2plot$p), "", df2plot$p)
  
  df2plot$se <- round((log(df2plot$upper) - log(df2plot$OR))/1.96, digits = 3)
  # Add blank column for the forest plot to display CI.
  # Adjust the column width with space, increase number of space below 
  # to have a larger area to draw the CI. 
  df2plot$`confounder adjusted outcome` <- paste(rep(" ", 20), collapse = " ")
  
  # Create confidence interval column to display
  df2plot$`OR (CI)` <- ifelse(is.na(df2plot$se), "",
                              sprintf("%.2f (%.2f-%.2f)",
                                      df2plot$OR, df2plot$lower, df2plot$upper))
  
  significant_row_indices = to_vec(
    for (i in seq_along(df2plot$p)) 
      if ((df2plot$p[[i]] != "")&(as.numeric(df2plot$p[[i]])< 0.05)) 
        i
    )
  
  df2plot$`p-value` <- df2plot$p
  df2plot$p <- NULL 
  
  names(df2plot)[2] <- "healthy"
  names(df2plot)[3] <- "psoriasis"
  
  
  subgroup_row_indices = to_vec(for (i in seq_along(df2plot$feature))
    if (!(grepl("    ",df2plot$feature[[i]]))) i)
  
  
  
  df2plot$feature <- to_vec(for (f in df2plot$feature)  
    gsub("\\_"," ",
         gsub("_cat","",
              gsub("_year_1","",
                   gsub("_year_3","",
                        gsub("_dichotomous","",
                             gsub("_dichotomous_4","",     
                                  gsub("_dichotomous_6","",
                                       gsub("_tertile","",f))))))))
  )
  
  tm <- forestploter::forest_theme(base_size = 10,
                                   # Confidence interval point shape, line type/color/width
                                   ci_pch = 15,
                                   ci_col = "#762a83",
                                   ci_fill = "black",
                                   ci_alpha = 1,
                                   ci_lty = 1,
                                   ci_lwd = 1.5,
                                   ci_Theight = 0.2, # Set an T end at the end of CI 
                                   # Reference line width/type/color
                                   refline_lwd = 1,
                                   refline_lty = "dashed",
                                   refline_col = "#ff0000")
  
  if (imputed_output){
      data_columns <- c(1,8:10)
      bold_columns <- c(3,4)
      ci_column = 2
      } else {
      data_columns <- c(1:3,8:10)
      bold_columns <- c(5,6)
      ci_column = 4
  }
  
  p <- forestploter::forest(df2plot[,data_columns],
                            est = df2plot$OR,
                            lower = df2plot$lower, 
                            upper = df2plot$upper,
                            sizes = 1,
                            ci_column = ci_column,
                            ref_line = 1,
                            arrow_lab = c("lower risk", "higher risk"),
                            title = title,
                            xlim = c(0, xlim_max),
                            ticks_at = c(0,1,
                                         seq(2,
                                             round(xlim_max,0),
                                             ifelse(xlim_max<=4,1,2)
                                         )
                            ),
                            theme = tm)
  
  
  
  g <- forestploter::edit_plot(p, 
                               row = subgroup_row_indices, 
                               col = 1, 
                               gp = gpar(fontface = "bold"))
  
  if(!is.null(significant_row_indices)){
    g <- forestploter::edit_plot(g, 
                                 row = significant_row_indices,
                                 col = bold_columns, 
                                 gp = gpar(fontface = "bold"))
  }
  
  return(g)
}

save_forest_plot <- function(forest_plot,filename){
  print(paste("saving forest plot to ",filename))
  
  ggplot2::ggsave(filename = filename, 
                  plot = forest_plot,
                  height = 3508,
                  width = 2480,
                  units = "px",
  )
}