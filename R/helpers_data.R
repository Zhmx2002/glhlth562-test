get_country_choices <- function() {
  cache <- WDI::WDIcache()
  
  countries <- cache$country %>%
    dplyr::filter(
      region != "Aggregates",
      !is.na(iso2c),
      iso2c != ""
    ) %>%
    dplyr::arrange(country)
  
  stats::setNames(countries$iso2c, countries$country)
}

get_indicator_choices <- function() {
  # Expanded curated list to improve usefulness without overwhelming the UI
  c(
    "Life Expectancy at Birth" = "SP.DYN.LE00.IN",
    "Infant Mortality Rate" = "SP.DYN.IMRT.IN",
    "Under-5 Mortality Rate" = "SH.DYN.MORT",
    "Maternal Mortality Ratio" = "SH.STA.MMRT",
    "Current Health Expenditure (% of GDP)" = "SH.XPD.CHEX.GD.ZS",
    "Current Health Expenditure per Capita (US$)" = "SH.XPD.CHEX.PC.CD",
    "Physicians (per 1,000 people)" = "SH.MED.PHYS.ZS",
    "Hospital Beds (per 1,000 people)" = "SH.MED.BEDS.ZS",
    "Immunization, DPT (% of children ages 12-23 months)" = "SH.IMM.IDPT",
    "Immunization, Measles (% of children ages 12-23 months)" = "SH.IMM.MEAS",
    "Population, Total" = "SP.POP.TOTL",
    "GDP per Capita (current US$)" = "NY.GDP.PCAP.CD",
    "Prevalence of Anemia in Women (%)" = "SH.ANM.ALLW.ZS",
    "Prevalence of Undernourishment (%)" = "SN.ITK.DEFC.ZS"
  )
}

get_wb_data <- function(country, indicator, start_year, end_year) {
  tryCatch({
    df <- WDI::WDI(
      country = country,
      indicator = indicator,
      start = start_year,
      end = end_year,
      extra = FALSE
    )
    
    if (nrow(df) == 0) {
      return(data.frame(year = numeric(0), value = numeric(0)))
    }
    
    # WDI returns a column named after the indicator code
    value_col <- indicator
    
    df_clean <- df %>%
      dplyr::select(year, all_of(value_col)) %>%
      dplyr::rename(value = all_of(value_col)) %>%
      dplyr::mutate(
        year = as.numeric(year),
        value = as.numeric(value)
      ) %>%
      dplyr::filter(!is.na(value)) %>%
      dplyr::arrange(year)
    
    df_clean
  }, error = function(e) {
    attr(empty <- data.frame(year = numeric(0), value = numeric(0)), "error_message") <- e$message
    empty
  })
}

generate_rule_based_interpretation <- function(df) {
  if (nrow(df) < 2) {
    return("Not enough data to generate a rule-based interpretation.")
  }
  
  first_val <- dplyr::first(df$value)
  last_val  <- dplyr::last(df$value)
  
  trend <- if (last_val > first_val) {
    "increasing"
  } else if (last_val < first_val) {
    "decreasing"
  } else {
    "stable"
  }
  
  paste0(
    "From ", min(df$year), " to ", max(df$year),
    ", the indicator shows an overall ", trend,
    " trend. The average value is ", round(mean(df$value, na.rm = TRUE), 2),
    ", with a minimum of ", round(min(df$value, na.rm = TRUE), 2),
    " and a maximum of ", round(max(df$value, na.rm = TRUE), 2), "."
  )
}

get_summary_stats <- function(df) {
  if (nrow(df) == 0) {
    return(data.frame(
      mean = NA_real_,
      median = NA_real_,
      min = NA_real_,
      max = NA_real_,
      n_years = 0
    ))
  }
  
  data.frame(
    mean = round(mean(df$value, na.rm = TRUE), 2),
    median = round(median(df$value, na.rm = TRUE), 2),
    min = round(min(df$value, na.rm = TRUE), 2),
    max = round(max(df$value, na.rm = TRUE), 2),
    n_years = nrow(df)
  )
}

build_ai_data_context <- function(df, country_name, indicator_name) {
  if (nrow(df) == 0) {
    return(NULL)
  }
  
  summary_text <- paste0(
    "Country: ", country_name, "\n",
    "Indicator: ", indicator_name, "\n",
    "Years covered: ", min(df$year), " to ", max(df$year), "\n",
    "Mean value: ", round(mean(df$value, na.rm = TRUE), 2), "\n",
    "Minimum value: ", round(min(df$value, na.rm = TRUE), 2), "\n",
    "Maximum value: ", round(max(df$value, na.rm = TRUE), 2), "\n",
    "Data points:\n",
    paste(paste0(df$year, ": ", round(df$value, 2)), collapse = "\n")
  )
  
  summary_text
}
