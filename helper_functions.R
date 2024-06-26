categorise_variable <- function(
    data,
    variable2categorise,  # = "c_102"
    category_variable,    # = "maternal_nutrition",
    breaks, 
    labels){
  
  data[[category_variable]] <- cut(as.vector(data[[variable2categorise]]),
                                   breaks = breaks, 
                                   labels = labels,
                                   include.lowest = TRUE)
  return(data)
}

# cumulative percentage plots
cumulative_percentage <- function(data, outcome, feature, 
                                  disease, inverse_cumul = FALSE ){
  
  inverse_cumulativesum <- function(freq_list){
    inverse_cum_sum = rev(cumsum(rev(freq_list)))
    
    return(inverse_cum_sum)
  }
  
  
  library(rlang)
  
  outcome <- sym(outcome)
  feature <- sym(feature)
  disease <- sym(disease)
  
  
  summary_table <- data %>% dplyr::select(!!outcome, !!feature) %>% 
    group_by(!!outcome,!!feature) %>% 
    summarise(freq = n()) %>%
    setNames(c(disease, feature, "freq")) %>%
    mutate(disease = recode_factor(!!disease, "0" = "no", "1" = "yes")) %>%
    mutate(
      cumul_freq = if (inverse_cumul == TRUE) inverse_cumulativesum(freq) else cumsum(freq), 
      cumul_perc = (cumul_freq/sum(freq))*100)
  
  
  print(summary_table)
  
  summary_table[feature] =  haven::as_factor(summary_table[feature])
  
  
  dictionary <- c(1,2,3,4,5,6,7,8,9)
  xlabel <- gsub("_", " ",
                 gsub("_cat"," ",
                      gsub("_dichotomous_6", " ", 
                           gsub("_dichotomous_4", " ", 
                                gsub("_tertile", " ", 
                                     all_parameters[
                                       all_parameters$variable2categorise == feature,]$category_variable[[1]])
                           )
                      )
                 )
  )
  
  p <- ggplot(summary_table, aes(!!feature, 
                                 cumul_perc, 
                                 colour = disease,
                                 group = disease)) + geom_line() +
    scale_x_continuous(breaks = dictionary) + 
    xlab(paste(xlabel, "(months)")) + 
    ylab("cumulative percentage (%)") + 
    labs(color = "psoriasis") +
    ylim(0,100)    
  
  return(p)
}



# fit univariate logistic regression models using complete-case data 
complete_case_univariate_logistic_regression <- function(variables2test,
                                                         dataframe2use){
  for (i in seq_along(variables2test)) {
    
    v = variables2test[[i]]
    print(v)
    
    curr_cc_data <- dataframe2use[complete.cases(dataframe2use[,c("Diagnos",v)]),]
    
    
    fit_cc_univ <- glm(as.formula(paste("Diagnos ~ ",v, collapse = "")), 
                       family = "binomial",
                       data = curr_cc_data
    )
    
    est_cc_univ <- tidy(fit_cc_univ, conf.int = TRUE, exponentiate = TRUE) %>%
      mutate_if(is.numeric,round,3) 
    est_cc_univ[,c("std.error","statistic")] <- NULL
    
    # extract p-values from model using Likelihood ratio
    est_cc_univ["p.value"] <- round((p_value(model = fit_cc_univ, 
                                             method = "LRT", 
                                             alternative = "two.sided"))$p, 
                                    digits = 3)
    
    is_factor <- is.factor(curr_cc_data[[v]])
    
    if(is_factor){
      est_cc_univ[grepl("Intercept",est_cc_univ$term),][,!(names(est_cc_univ) %in% c("term"))] <- NA
      # reformatting the subgroup and group positions for forest plot
      reformatted_term <- c()
      for(it in seq_along(est_cc_univ$term)) {
        
        if(!(grepl("Intercept",est_cc_univ$term[[it]]))) {
          reformatted_term <- c(reformatted_term,
                                gsub(v, "    ", est_cc_univ$term[[it]])
          )
        } else {
          reformatted_term <- c(reformatted_term,
                                paste("    ",levels(curr_cc_data[[v]])[[1]]))
        }
      }
      est_cc_univ$term <- reformatted_term
      
    }
    
    # counts per level
    if(is_factor){
      curr_counts <- curr_cc_data %>% tabyl(!!sym(v), Diagnos)
      names(curr_counts) <- c("term", "no", "yes")
    } else {
      curr_counts <- data.frame(term = v, 
                                no = curr_cc_data %>% filter(Diagnos==0) %>% nrow(),
                                yes = curr_cc_data %>% filter(Diagnos==1) %>% nrow())
    }
    
    rows2add <- est_cc_univ %>% filter(!grepl("Intercept",term))
    curr_counts$term <- rows2add$term
    rows2add <- full_join(curr_counts, rows2add, by = "term")
    
    # add a row for forestplot
    rows2add <- rbind(data.frame(
      term = v,
      no=c(NA),
      yes=c(NA),
      estimate=c(NA),
      p.value=c(NA),
      conf.low=c(NA),
      conf.high=c(NA)
    ),
    rows2add
    )
    
    if(i == 1){
      cc_univariate_regression_table <- rows2add
    } else{
      cc_univariate_regression_table <- rbind(cc_univariate_regression_table,
                                              rows2add)
    }
    
  }
  return(cc_univariate_regression_table)
  
}



# fit multivariable logistic regression models using complete-case data 

complete_case_multivariable_logistic_regression <- function(variables2test,
                                                            dataframe2use,
                                                            number_of_test = NA,
                                                            sex_specific = FALSE){
  
  # number of tests (for multiple testing correstion) is 
  # the total number of levels of all groups - number of groups (each group has one ref level)
  # this is the total number of pvalues reported, so p_bonferroni alpha/m correction
  
  if (is.na(number_of_test)){
    number_of_test <- length(
      unlist(
        all_parameters[
          all_parameters$category_variable %in% variables2test,]$labels
      )) - length(variables2test)
  }

  
  for (i in seq_along(variables2test)) {
    
    v = variables2test[[i]]
    print(v)
    
    if(sex_specific){
      curr_cc_data <- dataframe2use[
        complete.cases(dataframe2use[,c("Diagnos",
                                        v,
                                        "first_degree_psoriasis_heredity",
                                        "education_mother",
                                        "education_father",
                                        "gestational_age")]),]
      
      
      fit_cc_multi <- glm(
        as.formula(paste("Diagnos ~ ",v," + first_degree_psoriasis_heredity + education_mother + education_father + gestational_age", collapse = "")), 
        family = "binomial",
        data = curr_cc_data
      )
      
    } else {
      curr_cc_data <- dataframe2use[
        complete.cases(dataframe2use[,c("Diagnos",
                                        v,
                                        "first_degree_psoriasis_heredity",
                                        "education_mother",
                                        "education_father",
                                        "Sex_cat",
                                        "gestational_age")]),]
      
      
      fit_cc_multi <- glm(
        as.formula(paste("Diagnos ~ ",v," + first_degree_psoriasis_heredity + education_mother + education_father + Sex_cat + gestational_age", collapse = "")), 
        family = "binomial",
        data = curr_cc_data
      )
      
    }

    est_cc_multi <- tidy(fit_cc_multi, conf.int = TRUE, exponentiate = TRUE) %>%
      mutate_if(is.numeric,round,3) 
    
    est_cc_multi[,c("std.error","statistic")] <- NULL

    # extract p-values using likelihood ratio
    est_cc_multi["p.value"] <- round((p_value(model = fit_cc_multi, 
                                              method = "LRT", 
                                              alternative = "two.sided"))$p,
                                     digits = 3)
    # calculate adjusted CI for multiple testing "Bonferroni"
    adjusted_ci_bon <- confint(fit_cc_multi, level = (1-(0.05/number_of_test))) %>% 
      as.data.frame() %>% 
      mutate_if(is.numeric,exp) %>% 
      mutate_if(is.numeric,round,3)
    
    est_cc_multi["adj.bon.conf.low"] <- adjusted_ci_bon[names(adjusted_ci_bon)[1]]
    est_cc_multi["adj.bon.conf.high"] <- adjusted_ci_bon[names(adjusted_ci_bon)[2]]
    
    est_cc_multi <- est_cc_multi %>% 
      filter(grepl("Intercept",term)|grepl(v,term))
    
    is_factor <- is.factor(curr_cc_data[[v]])
    
    if(is_factor){
      est_cc_multi[grepl("Intercept",est_cc_multi$term),][,!(names(est_cc_multi) %in% c("term"))] <- NA
      # reformatting the subgroup and group positions
      reformatted_term <- c()
      for(it in seq_along(est_cc_multi$term)) {
        
        if(!(grepl("Intercept",est_cc_multi$term[[it]]))) {
          reformatted_term <- c(reformatted_term,
                                gsub(v, "    ", est_cc_multi$term[[it]])
          )
        } else {
          reformatted_term <- c(reformatted_term,
                                paste("    ",levels(curr_cc_data[[v]])[[1]]))
        }
      }
      est_cc_multi$term <- reformatted_term
      
    }    
    
    # counts per level
    if(is_factor){
      curr_counts <- curr_cc_data %>% tabyl(!!sym(v), Diagnos)
      names(curr_counts) <- c("term", "no", "yes")
    } else {
      curr_counts <- data.frame(term = v, 
                                no = curr_cc_data %>% filter(Diagnos==0) %>% nrow(),
                                yes = curr_cc_data %>% filter(Diagnos==1) %>% nrow())
    }
    
    rows2add <- est_cc_multi %>% filter(!grepl("Intercept",term))
    curr_counts$term <- rows2add$term
    rows2add <- full_join(curr_counts, rows2add, by = "term")
    
    # add a row for forestplot
    rows2add <- rbind(data.frame(
      term = v,
      no=c(NA),
      yes=c(NA),
      estimate=c(NA),
      p.value=c(NA),
      conf.low=c(NA),
      conf.high=c(NA),
      adj.bon.conf.low = c(NA),
      adj.bon.conf.high = c(NA)
    ),
    rows2add
    )  
    
    if(i == 1){
      cc_multivariable_regression_table <- rows2add
    } else{
      cc_multivariable_regression_table <- rbind(cc_multivariable_regression_table,
                                                 rows2add)
    }
    
  }
  
  return(cc_multivariable_regression_table)
}


# fit univariate logistic regression models and pool parallel imputation data


imputed_univariate_logistic_regression <- function(variables2test, 
                                                   mice_impute_object){
  
  imputed_psoriasis_data <- complete(mice_impute_object)
  
  for (i in seq_along(variables2test)) {
    
    v = variables2test[[i]]
    print(v)
    
    fit_imp_par_univ <- with(
      mice_impute_object, 
      glm(as.formula(paste("Diagnos ~ ",v, collapse = "")), family = "binomial"))
    
    
    est_imp_par_univ <- summary(pool(fit_imp_par_univ), conf.int = TRUE, exponentiate = TRUE)
    est_imp_par_univ[-1] <- round(est_imp_par_univ[-1], digits = 3) 
    
    est_imp_par_univ[["conf.low"]] <- est_imp_par_univ[["2.5 %"]] 
    est_imp_par_univ[["conf.high"]] <- est_imp_par_univ[["97.5 %"]] 
    est_imp_par_univ[,c("df", "std.error", "statistic", "2.5 %", "97.5 %")] <- NULL
    
    
    is_factor <- is.factor(mice_impute_object$data[[v]])
    
    if(is_factor){
      est_imp_par_univ[grepl("Intercept",est_imp_par_univ$term),][,!(names(est_imp_par_univ) %in% c("term"))] <- NA
      # reformatting the subgroup and group positions
      reformatted_term <- c()
      for(it in seq_along(est_imp_par_univ$term)) {
        
        if(!(grepl("Intercept",est_imp_par_univ$term[[it]]))) {
          reformatted_term <- c(reformatted_term,
                                gsub(v, "    ", est_imp_par_univ$term[[it]])
          )
        } else {
          reformatted_term <- c(reformatted_term,
                                paste("    ",levels(imputed_psoriasis_data[[v]])[[1]]))
        }
      }
      est_imp_par_univ$term <- reformatted_term
      
    }    
    
    # counts per level
    if(is_factor){
      curr_counts <- imputed_psoriasis_data %>% tabyl(!!sym(v), Diagnos)
      names(curr_counts) <- c("term", "no", "yes")
    } else {
      curr_counts <- data.frame(term = v, 
                                no = imputed_psoriasis_data %>% filter(Diagnos==0) %>% nrow(),
                                yes = imputed_psoriasis_data %>% filter(Diagnos==1) %>% nrow())
    }
    
    rows2add <- est_imp_par_univ %>% filter(!grepl("Intercept",term))
    curr_counts$term <- rows2add$term
    rows2add <- full_join(curr_counts, rows2add, by = "term")
    
    # add a row for forestplot
    rows2add <- rbind(data.frame(
      term = v,
      no=c(NA),
      yes=c(NA),
      estimate=c(NA),
      p.value=c(NA),
      conf.low=c(NA),
      conf.high=c(NA)
    ),
    rows2add
    )  
    
    if(i == 1){
      imp_univariate_regression_table <- rows2add
    } else{
      imp_univariate_regression_table <- rbind(imp_univariate_regression_table,
                                               rows2add)
    }
    
  }
  
  return(imp_univariate_regression_table)
}


# fit multivariable logistic regression models and pool parallel imputation data

imputed_multivariable_logistic_regression <- function(variables2test, 
                                                      mice_impute_object,
                                                      number_of_test = NA,
                                                      sex_specific = FALSE){
  
  imputed_psoriasis_data <- complete(mice_impute_object)
  
  # number of tests (for multiple testing correstion) is 
  # the total number of levels of all groups - number of groups (each group has one ref level)
  # this is the total number of pvalues reported, so p_bonferroni alpha/m correction
  if (is.na(number_of_test)){
    number_of_test <- length(
      unlist(
        all_parameters[
          all_parameters$category_variable %in% variables2test,]$labels
      )) - length(variables2test)
  }
  
  
  for (i in seq_along(variables2test)) {
    v = variables2test[[i]]
    # print(v)
    
    if(sex_specific){
      fit_imp_par_multi <- with(
        mice_impute_object, 
        glm(as.formula(paste("Diagnos ~",v," + first_degree_psoriasis_heredity + education_mother + education_father + gestational_age", collapse = "")), family = "binomial"))
    } else {
      fit_imp_par_multi <- with(
        mice_impute_object, 
        glm(as.formula(paste("Diagnos ~",v," + first_degree_psoriasis_heredity + education_mother + education_father + Sex_cat + gestational_age", collapse = "")), family = "binomial"))
    }
    
    est_imp_par_multi <- summary(pool(fit_imp_par_multi), conf.int = TRUE, exponentiate = TRUE)
    est_imp_par_multi[-1] <- round(est_imp_par_multi[-1], digits = 3)
    
    est_imp_par_multi[["conf.low"]] <- est_imp_par_multi[["2.5 %"]] 
    est_imp_par_multi[["conf.high"]] <- est_imp_par_multi[["97.5 %"]]     
    est_imp_par_multi[,c("df","std.error", "statistic","2.5 %","97.5 %")] <- NULL
    
    # calculate adjusted CI for multiple testing "Bonferroni"
    adjusted_ci_bon <- summary(pool(fit_imp_par_multi), 
                               conf.level = (1-(0.05/number_of_test)),
                               conf.int = TRUE, 
                               exponentiate = TRUE) %>% 
      as.data.frame() %>% mutate_if(is.numeric,round,3)
    
    est_imp_par_multi["adj.bon.conf.low"] <- adjusted_ci_bon[names(adjusted_ci_bon)[ncol(adjusted_ci_bon)-1]]
    est_imp_par_multi["adj.bon.conf.high"] <- adjusted_ci_bon[names(adjusted_ci_bon)[ncol(adjusted_ci_bon)]]
    
    est_imp_par_multi <- est_imp_par_multi %>% 
      filter(grepl("Intercept",term)|grepl(v,term))
    
    is_factor <- is.factor(imputed_psoriasis_data[[v]])
    
    if(is_factor){
      est_imp_par_multi[grepl("Intercept",est_imp_par_multi$term),][,!(names(est_imp_par_multi) %in% c("term"))] <- NA
      # reformatting the subgroup and group positions
      reformatted_term <- c()
      for(it in seq_along(est_imp_par_multi$term)) {
        
        if(!(grepl("Intercept",est_imp_par_multi$term[[it]]))) {
          reformatted_term <- c(reformatted_term,
                                gsub(v, "    ", est_imp_par_multi$term[[it]])
          )
        } else {
          reformatted_term <- c(reformatted_term,
                                paste("    ",levels(imputed_psoriasis_data[[v]])[[1]]))
        }
      }
      est_imp_par_multi$term <- reformatted_term
      
    }    
    
    # counts per level
    if(is_factor){
      curr_counts <- imputed_psoriasis_data %>% tabyl(!!sym(v), Diagnos)
      names(curr_counts) <- c("term", "no", "yes")
    } else {
      curr_counts <- data.frame(term = v, 
                                no = imputed_psoriasis_data %>% filter(Diagnos==0) %>% nrow(),
                                yes = imputed_psoriasis_data %>% filter(Diagnos==1) %>% nrow())
    }
    
    rows2add <- est_imp_par_multi %>% filter(!grepl("Intercept",term))
    curr_counts$term <- rows2add$term
    rows2add <- full_join(curr_counts, rows2add, by = "term")
    
    # add a row for forestplot
    rows2add <- rbind(data.frame(
      term = v,
      no=c(NA),
      yes=c(NA),
      estimate=c(NA),
      p.value=c(NA),
      conf.low=c(NA),
      conf.high=c(NA),
      adj.bon.conf.low = c(NA),
      adj.bon.conf.high = c(NA)
    ),
    rows2add
    )  
    
    if(i == 1){
      imp_multivariable_regression_table <- rows2add
    } else{
      imp_multivariable_regression_table <- rbind(imp_multivariable_regression_table,
                                                  rows2add)
    }
    
  }

  return(imp_multivariable_regression_table)
  
}


# flextable

regression_table2flextable <- function(regression_table){
  return(regression_table %>%
    mutate(characteristics = ifelse(!grepl("    ",term),term,NA),
           level = ifelse(grepl("    ",term),term,NA))  %>%
    dplyr::select(characteristics, level, no,yes,estimate,conf.low,conf.high,p.value) %>%
    filter(is.na(yes)|yes!=0) %>% 
      filter(is.na(estimate)|estimate != 0) %>%
      filter(is.na(conf.low)|conf.low != 0) %>%
      mutate(
        characteristics = gsub("_"," ",
                               gsub("_cat"," ",
                                    gsub("_cat_year_3"," ",
                                         gsub("_cat_year_1"," ",
                                              gsub("_dichotomous_4"," ", 
                                                   gsub("_dichotomous_6"," ",
                                                        characteristics)))))),
        level = gsub("_"," ",
                               gsub("_cat"," ",
                                    gsub("_cat_year_3"," ",
                                         gsub("_cat_year_1"," ",
                                              gsub("_dichotomous_4"," ", 
                                                   gsub("_dichotomous_6"," ",
                                                        level))))))
        ) %>%
    flextable() %>% color(~ p.value<0.05, ~p.value , color = "red")
  )
  
} 

# forest plot


forest_from_table <- function(df2plot,
                              title = "early nutrition year 1",
                              univariate = TRUE,
                              imputed_output = FALSE){
  
  xlim_max = round(max(df2plot$estimate, na.rm = TRUE),0) + 2
  
  names(df2plot) <- c("feature", "no", "yes", "OR", "p", "lower", "upper", "p.bon", "p.bh")
  
  df2plot$OR <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$OR[[i]])) as.numeric(df2plot$OR[[i]]) else as.numeric(NA))
  df2plot$p <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$p[[i]])) as.numeric(df2plot$p[[i]]) else as.numeric(NA))
  
  df2plot$p.bon <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$p.bon[[i]])) as.numeric(df2plot$p.bon[[i]]) else as.numeric(NA))
  df2plot$p.bh <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$p.bh[[i]])) as.numeric(df2plot$p.bh[[i]]) else as.numeric(NA))
  
  df2plot <- df2plot %>% dplyr::select(feature, no, yes,OR, lower,upper,p, p.bon, p.bh)
  
  subgroup_patterns <- to_vec(for (sgp in unique(unlist(all_parameters$labels))) gsub("_"," ",sgp))
  
  df2plot$feature <- ifelse(df2plot$feature %in% subgroup_patterns,
                            paste0("    ",df2plot$feature), 
                            df2plot$feature
  )
  
  df2plot$no <- ifelse(is.na(df2plot$no), "", df2plot$no)
  df2plot$yes <- ifelse(is.na(df2plot$yes), "", df2plot$yes)
  df2plot$p <- ifelse(is.na(df2plot$p), "", df2plot$p)
  
  df2plot$p.bon <- ifelse(is.na(df2plot$p.bon), "", df2plot$p.bon)
  df2plot$p.bh <- ifelse(is.na(df2plot$p.bh), "", df2plot$p.bh)
  
  df2plot$se <- round((log(df2plot$upper) - log(df2plot$OR))/1.96, digits = 3)
  # Add blank column for the forest plot to display CI.
  # Adjust the column width with space, increase number of space below 
  # to have a larger area to draw the CI. 
  df2plot$`confounder adjusted outcome` <- paste(rep(" ", 20), collapse = " ")
  
  # Create confidence interval column to display
  df2plot$`OR (CI)` <- ifelse(is.na(df2plot$se), "",
                                  sprintf("%.2f (%.2f-%.2f)",
                                          df2plot$OR, df2plot$lower, df2plot$upper))

  if (univariate){
    significant_row_indices = to_vec( for (i in seq_along(df2plot$p)) 
      if ((df2plot$p[[i]] != "")&(as.numeric(df2plot$p[[i]])< 0.05))
        i)
  } else {
    significant_row_indices = to_vec( for (i in seq_along(df2plot$p.bh)) 
      if ((df2plot$p.bh[[i]] != "")&(as.numeric(df2plot$p.bh[[i]])< 0.05))
        i)
  }
    
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
    if (univariate){
      data_columns <- c(1,10:12)
      bold_columns <- c(4)
      ci_column = 2
    } else {
      data_columns <- c(1,10:12,7:8)
      bold_columns <- c(6)
      ci_column = 2
    }

  } else {
    if (univariate){
      data_columns <- c(1:3,10:12)
      bold_columns <- c(6)
      ci_column = 4
    } else {
      data_columns <- c(1:3,10:12,7:8)
      bold_columns <- c(8)
      ci_column = 4
    }

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


# multiple testing forest plot


multiple_testing_forest_from_table <- function(df2plot,
                              title = "early nutrition year 1",
                              imputed_output = FALSE){
  
  xlim_max = round(max(df2plot$estimate, na.rm = TRUE),0) + 2
  
  names(df2plot) <- c("feature", "no", "yes", "OR", "p", "lower", "upper","bon.lower", "bon.upper", "p.bon", "p.bh")
  
  df2plot$OR <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$OR[[i]])) as.numeric(df2plot$OR[[i]]) else as.numeric(NA))
  df2plot$p <- to_vec(for (i in seq(1,nrow(df2plot))) if (!is.na(df2plot$p[[i]])) as.numeric(df2plot$p[[i]]) else as.numeric(NA))
  
  
  df2plot <- df2plot %>% dplyr::select(feature, no, yes,OR, lower,upper, p, bon.lower, bon.upper, p.bon, p.bh)
  
  subgroup_patterns <- to_vec(for (sgp in unique(unlist(all_parameters$labels))) gsub("_"," ",sgp))
  
  df2plot$feature <- ifelse(df2plot$feature %in% subgroup_patterns,
                            paste0("    ",df2plot$feature), 
                            df2plot$feature
  )
  
  df2plot$no <- ifelse(is.na(df2plot$no), "", df2plot$no)
  df2plot$yes <- ifelse(is.na(df2plot$yes), "", df2plot$yes)
  df2plot$p <- ifelse(is.na(df2plot$p), "", df2plot$p)
  
  df2plot$p.bon <- ifelse(is.na(df2plot$p.bon), "", df2plot$p.bon)
  df2plot$p.bh <- ifelse(is.na(df2plot$p.bh), "", df2plot$p.bh)
  
  df2plot$se <- round((log(df2plot$upper) - log(df2plot$OR))/1.96, digits = 3)
  # Add blank column for the forest plot to display CI.
  # Adjust the column width with space, increase number of space below 
  # to have a larger area to draw the CI. 
  df2plot$`outcome` <- paste(rep(" ", 15), collapse = " ")

  # df2plot$`confounder adjusted` <- paste(rep(" ", 15), collapse = " ")
  # df2plot$`Bonferroni adjusted` <- paste(rep(" ", 15), collapse = " ")
  
  estimate = list(df2plot$OR,df2plot$OR)
  
  df2plot$`OR` <- ifelse(is.na(df2plot$se), "", sprintf("%.2f", df2plot$OR))
  # Create confidence interval column to display
  df2plot$`95% CI` <- ifelse(is.na(df2plot$se), "", 
                             sprintf("(%.2f-%.2f)",
                                     df2plot$lower, df2plot$upper))
  df2plot$`Bonferroni CI` <- ifelse(is.na(df2plot$se), "",
                                  sprintf("(%.2f-%.2f)",
                                          df2plot$bon.lower, df2plot$bon.upper))

  
  # df2plot$`p-value` <- df2plot$p
  # df2plot$p <- NULL 
  
  names(df2plot)[2] <- "healthy"
  names(df2plot)[3] <- "psoriasis"
  
  
  subgroup_row_indices = to_vec(for (i in seq_along(df2plot$feature))
    if (!(grepl("    ",df2plot$feature[[i]]))) i)
  
  # significant_row_indices = to_vec( for (i in seq_along(df2plot$`p-value`)) 
  #   if ((df2plot$`p-value`[[i]] != "")&(as.numeric(df2plot$`p-value`[[i]])< 0.05))
  #     i)
  
  significant_row_indices = to_vec( for (i in seq_along(df2plot$p.bh)) 
    if ((df2plot$p.bh[[i]] != "")&(as.numeric(df2plot$p.bh[[i]])< 0.05))
      i)
  
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
                                   # ci_col = "#762a83",
                                   ci_fill = "black",
                                   ci_alpha = 1,
                                   ci_lty = 1,
                                   ci_lwd = 1.5,
                                   ci_col = c("#ff0000", "#0000ff"),
                                   legend_name = "confidence interval:",
                                   legend_value = c("no correction", "bonferroni"),
                                   legend_position = "bottom",
                                   ci_Theight = 0.2, # Set an T end at the end of CI
                                   # Reference line width/type/color
                                   refline_lwd = 1,
                                   refline_lty = "dashed",
                                   refline_col = "#000000")
  
  
  if (imputed_output){
    data_columns <- c(1,4,14,7,15,10,13,11)  
    bold_columns <- c(2,8)
    ci_column = 7
  } else {
    data_columns <- c(1:4,14,7,15,10,13,11)
    bold_columns <- c(4,10)
    ci_column = 9
  }
  
  
  p <- forestploter::forest(df2plot[,data_columns],
                            est = estimate,
                            lower = list(df2plot$lower,df2plot$bon.lower),
                            upper = list(df2plot$upper,df2plot$bon.upper),
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

# correction of p-value 
add_pvalue_correction <- function(dataframe2correct){
  
  ps <- dataframe2correct$p.value
  ps2process <- ps[!is.na(ps)]
  
  # adjusted p.value
  bon_adjusted_ps <- round(p.adjust(ps2process, method = "bonferroni"),3)
  bh_adjusted_ps <- round(p.adjust(ps2process, method = "BH"),3)
  
  ip = 1
  
  bon_pval2replace <- c()
  bh_pval2replace <- c()
  
  for (pval in ps){
    if(!is.na(pval)){
      bon_pval2replace <- c(bon_pval2replace, bon_adjusted_ps[[ip]])
      bh_pval2replace <- c(bh_pval2replace, bh_adjusted_ps[[ip]])
      ip = ip + 1
    } else{
      bon_pval2replace <- c(bon_pval2replace, pval)
      bh_pval2replace <- c(bh_pval2replace, pval)
    }
  } 

  dataframe2correct$p.bon <- bon_pval2replace
  dataframe2correct$p.bh <- bh_pval2replace
  
  return(dataframe2correct)
}


# help find middle point to split long regression table into two

half_mark <- function(dataframe2split){
  one_half = as.integer(nrow(dataframe2split)/2)
  
  for (i in seq(one_half, nrow(dataframe2split))){
    if (!grepl("    ",dataframe2split$term[i])){
      one_half = one_half - 1
      break
    } else{
      one_half = one_half + 1
    }
  }
  return(one_half)
}


# save forest plot

save_forest_plot <- function(forest_plot,filename){
  print(paste("saving forest plot to ",filename))
  
  ggplot2::ggsave(filename = filename, 
                  plot = forest_plot,
                  height = 3508,
                  width = 2480,
                  units = "px",
  )
}