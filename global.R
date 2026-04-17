library(shiny)
library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)
library(WDI)
library(shinycssloaders)
library(bslib)
library(DT)

source("R/helpers_data.R")
source("R/helpers_ai.R")

country_choices <- get_country_choices()
indicator_choices <- get_indicator_choices()

source("R/ui.R")
source("R/server.R")
