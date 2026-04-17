# Interactive Global Health Trend Explorer

## Overview
Interactive Global Health Trend Explorer is a modular Shiny application that allows users to explore World Bank health and development indicators across countries and years. Users can select a country, choose an indicator, define a year range, visualize the trend, review summary statistics, inspect raw data, and generate both rule-based and AI-generated interpretations.

This revised version was developed in response to project feedback requesting:
- broader country and indicator coverage
- improved code organization
- stronger documentation
- more robust error handling
- real GenAI/LLM integration instead of only rule-based text generation

## Features
- Expanded country list using the `WDI` package
- Expanded indicator list covering multiple global health and development measures
- Adjustable year range
- Time-series visualization of World Bank indicator trends
- Summary statistics table
- Rule-based interpretation of the selected trend
- AI-generated interpretation using Duke AI Gateway with a GPT model
- Raw data table
- CSV download option
- Basic error handling for API/data retrieval failures

## Data Source
This application uses World Bank World Development Indicators data through the `WDI` R package.

Example endpoint format:
`https://api.worldbank.org/v2/country/{country}/indicator/{indicator}?format=json&date={start}:{end}`

The app retrieves annual indicator values for the selected country and year range, then formats the result for plotting, summary statistics, and interpretation.

## AI Integration
This app uses Duke AI Gateway with an OpenAI-compatible API call for GPT-based interpretation of selected indicator trends.

The AI interpretation workflow is:
1. summarize the selected country-indicator time series
2. build a prompt from the selected data
3. send the prompt to a GPT model through Duke AI Gateway
4. return a short interpretation of the trend to the user

This AI-based interpretation was added to address project feedback requesting a real LLM-based feature rather than only an if-else rule-based summary.

## Project Structure
```text
global_health_trend_explorer/
├── app.R
├── global.R
├── README.md
├── .gitignore
├── .Renviron        # local only, not committed
└── R/
    ├── helpers_data.R
    ├── helpers_ai.R
    ├── ui.R
    └── server.R