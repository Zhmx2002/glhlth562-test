app_ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  
  titlePanel("Interactive Global Health Trend Explorer"),
  
  div(
    style = "margin-bottom: 15px;",
    p("Explore World Bank health and development indicators across countries and time."),
    p("This version includes both rule-based and AI-generated trend interpretation.")
  ),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      selectizeInput(
        "country",
        "Select Country",
        choices = country_choices,
        selected = "US",
        options = list(placeholder = "Choose a country")
      ),
      
      selectizeInput(
        "indicator",
        "Select Indicator",
        choices = indicator_choices,
        selected = "SP.DYN.LE00.IN",
        options = list(placeholder = "Choose an indicator")
      ),
      
      sliderInput(
        "years",
        "Select Year Range",
        min = 1960,
        max = as.numeric(format(Sys.Date(), "%Y")),
        value = c(2000, 2020),
        sep = ""
      ),
      
      actionButton("refresh", "Load Data", class = "btn-primary"),
      br(), br(),
      actionButton("ai_btn", "Generate AI Interpretation", class = "btn-success"),
      br(), br(),
      
      helpText("Tip: AI interpretation requires a Gemini API key stored in .Renviron.")
    ),
    
    mainPanel(
      width = 9,
      
      tabsetPanel(
        tabPanel(
          "Visualization",
          br(),
          shinycssloaders::withSpinner(plotOutput("trendPlot", height = "400px")),
          br(),
          h4("Summary Statistics"),
          tableOutput("summaryStats")
        ),
        
        tabPanel(
          "Interpretation",
          br(),
          h4("Rule-Based Interpretation"),
          uiOutput("ruleInterpretation"),
          br(),
          h4("AI-Generated Interpretation"),
          shinycssloaders::withSpinner(uiOutput("aiInterpretation"))
        ),
        
        tabPanel(
          "Raw Data",
          br(),
          DT::dataTableOutput("rawTable"),
          br(),
          downloadButton("downloadData", "Download CSV")
        )
      ),
      
      br(),
      uiOutput("statusMessage")
    )
  )
)