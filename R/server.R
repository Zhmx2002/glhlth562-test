app_server <- function(input, output, session) {
  
  wb_data <- eventReactive(input$refresh, {
    get_wb_data(
      country = input$country,
      indicator = input$indicator,
      start_year = input$years[1],
      end_year = input$years[2]
    )
  }, ignoreNULL = FALSE)
  
  output$statusMessage <- renderUI({
    df <- wb_data()
    err <- attr(df, "error_message")
    
    if (!is.null(err)) {
      div(
        style = "color: #a94442; background-color: #f2dede; padding: 10px; border-radius: 6px;",
        paste("Data retrieval error:", err)
      )
    } else if (nrow(df) == 0) {
      div(
        style = "color: #8a6d3b; background-color: #fcf8e3; padding: 10px; border-radius: 6px;",
        "No data were returned for the selected country, indicator, and year range."
      )
    } else {
      div(
        style = "color: #3c763d; background-color: #dff0d8; padding: 10px; border-radius: 6px;",
        paste("Loaded", nrow(df), "annual observations successfully.")
      )
    }
  })
  
  output$trendPlot <- renderPlot({
    df <- wb_data()
    
    if (is.null(df) || nrow(df) == 0) {
      plot.new()
      text(0.5, 0.5, "No data available for plotting.")
      return(invisible(NULL))
    }
    
    country_name <- names(country_choices)[match(input$country, country_choices)]
    indicator_name <- names(indicator_choices)[match(input$indicator, indicator_choices)]
    
    ggplot(df, aes(x = year, y = value)) +
      geom_line(linewidth = 1) +
      geom_point(size = 2) +
      labs(
        title = paste(indicator_name, "in", country_name),
        subtitle = paste("World Bank annual data,", min(df$year), "to", max(df$year)),
        x = "Year",
        y = indicator_name
      ) +
      theme_minimal(base_size = 13)
  })
  
  output$summaryStats <- renderTable({
    df <- wb_data()
    get_summary_stats(df)
  }, rownames = FALSE)
  
  output$ruleInterpretation <- renderUI({
    df <- wb_data()
    
    div(
      style = "white-space: pre-wrap;",
      as.character(generate_rule_based_interpretation(df))
    )
  })
  
  output$aiInterpretation <- renderUI({
    if (input$ai_btn == 0) {
      return(
        div(
          style = "white-space: pre-wrap;",
          "Click 'Generate AI Interpretation' to create an AI summary."
        )
      )
    }
    
    df <- wb_data()
    
    if (nrow(df) == 0) {
      return(
        div(
          style = "white-space: pre-wrap;",
          "No data available. Please load a valid country, indicator, and year range first."
        )
      )
    }
    
    country_name <- names(country_choices)[match(input$country, country_choices)]
    indicator_name <- names(indicator_choices)[match(input$indicator, indicator_choices)]
    
    data_context <- build_ai_data_context(df, country_name, indicator_name)
    prompt <- build_ai_prompt(data_context)
    result <- call_duke_gpt_api(prompt)
    
    if (is.null(result) || length(result) == 0) {
      return(
        div(
          style = "white-space: pre-wrap;",
          "No AI response was returned."
        )
      )
    }
    
    div(
      style = "white-space: pre-wrap;",
      paste(as.character(result), collapse = "\n")
    )
  })
  
  output$rawTable <- DT::renderDataTable({
    df <- wb_data()
    
    DT::datatable(
      df,
      rownames = FALSE,
      options = list(pageLength = 10, autoWidth = TRUE)
    )
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("wb_data_", input$country, "_", input$indicator, ".csv")
    },
    content = function(file) {
      write.csv(wb_data(), file, row.names = FALSE)
    }
  )
}