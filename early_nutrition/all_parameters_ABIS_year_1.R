################################################################################
load_all_parameter <- function(){
  all_parameters <- data.frame(
    matrix(ncol = 4, nrow = 0)
  )
  colnames(all_parameters) <- c("variable2categorise",
                                "category_variable",
                                "breaks",
                                "labels")
  
  
  # b_5
  # variable2categorise = list("b_5")
  # category_variable = list("exclusive_breastfeeding_tertile")
  # breaks = list(c(0,3,6,Inf))
  # labels = list(c("<=3","4-6",">=7"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_5
  variable2categorise = list("b_5")
  category_variable = list("exclusive_breastfeeding_dichotomous_4")
  breaks = list(c(0,4,Inf))
  labels = list(c("<=4",">4"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_5
  # variable2categorise = list("b_5")
  # category_variable = list("exclusive_breastfeeding_dichotomous_6")
  # breaks = list(c(0,6,Inf))
  # labels = list(c("<=6",">6"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_6
  # variable2categorise = list("b_6")
  # category_variable = list("infant_formula_tertile")
  # breaks = list(c(0,3,6,Inf))
  # labels = list(c("<=3","4-6",">=7"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_6
  variable2categorise = list("b_6")
  category_variable = list("infant_formula_dichotomous_4")
  breaks = list(c(0,4,Inf))
  labels = list(c("<=4",">4"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  
  # b_6
  # variable2categorise = list("b_6")
  # category_variable = list("infant_formula_dichotomous_6")
  # breaks = list(c(0,6,Inf))
  # labels = list(c("<=6",">6"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_7a
  variable2categorise = list("b_7a")
  category_variable = list("infant_formula_without_cowmilk")
  breaks = list(c(0,1,2))
  labels = list(c("yes","no"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_7b
  # variable2categorise = list("b_7b")
  # category_variable = list("infant_formula_without_cowmilk_tertile")
  # breaks = list(c(0,3,6,Inf))
  # labels = list(c("<=3","4-6",">=7"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_7b
  # variable2categorise = list("b_7b")
  # category_variable = list("infant_formula_without_cowmilk_dichotomous_4")
  # breaks = list(c(0,4,Inf))
  # labels = list(c("<=4",">4"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_7b
  # variable2categorise = list("b_7b")
  # category_variable = list("infant_formula_without_cowmilk_dichotomous_6")
  # breaks = list(c(0,6,Inf))
  # labels = list(c("<=6",">6"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_8
  # variable2categorise = list("b_8")
  # category_variable = list("cow_milk_introduction_dichotomous_4")
  # breaks = list(c(0,4,Inf))
  # labels = list(c("<=4",">4"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_8
  variable2categorise = list("b_8")
  category_variable = list("cow_milk_introduction_dichotomous_6")
  breaks = list(c(0,6,Inf))
  labels = list(c("<=6",">6"))

  all_parameters <- rbind(
    all_parameters,
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_9  
  # variable2categorise = list("b_9")
  # category_variable = list("gluten_tertile")
  # breaks = list(c(0,3,6,Inf))
  # labels = list(c("<=3","4-6",">=7"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #     )
  #   )
  
  # b_9  
  variable2categorise = list("b_9")
  category_variable = list("gluten_dichotomous_4")
  breaks = list(c(0,4,Inf))
  labels = list(c("<=4",">4"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_9  
  # variable2categorise = list("b_9")
  # category_variable = list("gluten_dichotomous_6")
  # breaks = list(c(0,6,Inf))
  # labels = list(c("<=6",">6"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  
  # b_10
  # variable2categorise = list("b_10")
  # category_variable = list("total_breastfeeding_tertile")
  # breaks = list(c(0,3,6,Inf))
  # labels = list(c("<=3","4-6",">=7"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #     )
  #   )
  
  
  # b_10
  variable2categorise = list("b_10")
  category_variable = list("total_breastfeeding_dichotomous_4")
  breaks = list(c(0,4,Inf))
  labels = list(c("<=4",">4"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # # b_10
  # variable2categorise = list("b_10")
  # category_variable = list("total_breastfeeding_dichotomous_5")
  # breaks = list(c(0,5,Inf))
  # labels = list(c("<=5",">5"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  
  # # b_10
  # variable2categorise = list("b_10")
  # category_variable = list("total_breastfeeding_dichotomous_6")
  # breaks = list(c(0,6,Inf))
  # labels = list(c("<=6",">6"))
  # 
  # all_parameters <- rbind(
  #   all_parameters,
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  
  # b_45
  variable2categorise = list("b_45")
  category_variable = list("vitamin_A_and_D")
  breaks = list(c(0,1,Inf))
  labels = list(c("yes","no"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_46
  variable2categorise = list("b_46")
  category_variable = list("other_vitamin")
  breaks = list(c(0,1,Inf))
  labels = list(c("yes","no"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  
  # b_49
  variable2categorise = list("b_49")
  category_variable = list("bread_per_day")
  breaks = list(c(0,1,2,5))
  labels = list(c("none","1-2 times","3-5 times or more"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  
  # b_53
  variable2categorise = list("b_53")
  category_variable = list("fruits_berries")
  breaks = list(c(0,1,2,4))
  labels = list(c("daily","3-5 times/week", "seldom or 1-2 times/week"))
  # labels = list(c("daily","3-5 times/week", "1-2 times/week", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  
  # b_54
  variable2categorise = list("b_54")
  category_variable = list("vegetables")
  breaks = list(c(0,1,2,4))
  labels = list(c("daily","3-5 times/week", "1-2 times/week or seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_55  
  variable2categorise = list("b_55")
  category_variable = list("potatoes")
  breaks = list(c(0,1,2,3,4))
  labels = list(c("daily","3-5 times/week", "1-2 times/week", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  
  # b_56  
  variable2categorise = list("b_56")
  category_variable = list("fish_lake")
  breaks = list(c(0,3,4))
  labels = list(c("frequently", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_57
  variable2categorise = list("b_57")
  category_variable = list("fish_Baltic")
  breaks = list(c(0,2,3,4))
  labels = list(c("3-5 times/week to daily", "1-2 times/week", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_58
  variable2categorise = list("b_58")
  category_variable = list("fish_other")
  breaks = list(c(0,2,3,4))
  labels = list(c("3-5 times/week to daily", "1-2 times/week", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # fish
  variable2categorise = list("fish")
  category_variable = list("fish_cat_year_1")
  breaks = list(c(0,2,3,4))
  labels = list(c("3-5 times/week or more","1-2 times/week","seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # # fish
  # variable2categorise = list("fish")
  # category_variable = list("fish_dichotomous")
  # breaks = list(c(0,2,4))
  # labels = list(c("3-5 times/week - daily","1-2 times/week - seldom"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )
  
  # b_59
  variable2categorise = list("b_59")
  category_variable = list("egg")
  breaks = list(c(0,3,4))
  labels = list(c("frequently", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_60
  variable2categorise = list("b_60")
  category_variable = list("meat_game")
  breaks = list(c(0,3,4))
  labels = list(c("frequently", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_61
  variable2categorise = list("b_61")
  category_variable = list("beef")
  breaks = list(c(0,3,4))
  labels = list(c("frequnetly", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_62
  variable2categorise = list("b_62")
  category_variable = list("pork")
  breaks = list(c(0,3,4))
  labels = list(c("frequently", "seldom"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # # b_65
  variable2categorise = list("b_65")
  category_variable = list("chocolate")
  breaks = list(c(0,3,4))
  labels = list(c("frequently", "seldom"))

  all_parameters <- rbind(
    all_parameters,
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
   
  # # b_66
  variable2categorise = list("b_66")
  category_variable = list("sweets_other")
  breaks = list(c(0,3,4))
  labels = list(c("frequent", "seldom"))

  all_parameters <- rbind(
    all_parameters,
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  # b_66
  # variable2categorise = list("b_66")
  # category_variable = list("sweets_other")
  # breaks = list(c(0,1,2,3,4))
  # labels = list(c("daily","3-5 times/week", "1-2 times/week", "seldom"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )  
  
  
  # fr_12
  # variable2categorise = list("fr_12")
  # category_variable = list("gestational_age_dichotomous")
  # breaks = list(c(0,37,Inf))
  # labels = list(c("preterm", "normal"))
  # 
  # all_parameters <- rbind(
  #   all_parameters, 
  #   data.frame(
  #     I(variable2categorise), I(category_variable), I(breaks), I(labels)
  #   )
  # )  
  
  # fr_27
  variable2categorise = list("fr_27")
  category_variable = list("education_mother")
  breaks = list(c(0,1,2,3,4,5,6))
  labels = list(c("compulsory_school_9_year",
                  "upper_secondary_school_practical_line",
                  "upper_secondary_school_theoretical_line",
                  "community_college",
                  "university_1-3_years",
                  "university_3,5_years_or_more"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )  
  
  
  # fr_28
  variable2categorise = list("fr_28")
  category_variable = list("education_father")
  breaks = list(c(0,1,2,3,4,5,6))
  labels = list(c("compulsory_school_9_year",
                  "upper_secondary_school_practical_line",
                  "upper_secondary_school_theoretical_line",
                  "community_college",
                  "university_1-3_years",
                  "university_3,5_years_or_more"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )  
  
  # Gender
  variable2categorise = list("Gender")
  category_variable = list("Sex_cat")
  breaks = list(c(-1,0,1))
  labels = list(c("boy", "girl"))
  
  all_parameters <- rbind(
    all_parameters, 
    data.frame(
      I(variable2categorise), I(category_variable), I(breaks), I(labels)
    )
  )
  
  return(as.data.frame(all_parameters))
}

all_parameters <- load_all_parameter()