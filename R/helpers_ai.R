build_ai_prompt <- function(data_context) {
  paste(
    "You are helping interpret a World Bank time series for a public health dashboard.",
    "Using the data below, write a concise interpretation in 3 to 5 sentences.",
    "Describe the general trend, mention any notable changes, explain one possible public health or policy relevance,",
    "and include one caution that this is descriptive and not causal.",
    "Do not invent facts that are not supported by the data.",
    "",
    data_context,
    sep = "\n"
  )
}

call_duke_gpt_api <- function(prompt, model = "GPT 4.1") {
  token <- Sys.getenv("LITELLM_TOKEN")
  
  if (identical(token, "")) {
    return("Duke AI Gateway token not found. Add LITELLM_TOKEN to your .Renviron file and restart R.")
  }
  
  url <- "https://litellm.oit.duke.edu/v1/chat/completions"
  
  body <- list(
    model = model,
    messages = list(
      list(
        role = "user",
        content = prompt
      )
    )
  )
  
  tryCatch({
    res <- httr::POST(
      url = url,
      httr::add_headers(
        Authorization = paste("Bearer", token)
      ),
      body = body,
      encode = "json",
      httr::content_type_json()
    )
    
    if (httr::status_code(res) != 200) {
      msg <- httr::content(res, "text", encoding = "UTF-8")
      return(paste("Duke GPT request failed:", msg))
    }
    
    parsed <- jsonlite::fromJSON(
      httr::content(res, "text", encoding = "UTF-8"),
      simplifyVector = FALSE
    )
    
    text_out <- parsed$choices[[1]]$message$content
    
    if (is.null(text_out) || identical(text_out, "")) {
      return("Duke GPT returned an empty response.")
    }
    
    as.character(text_out)
  }, error = function(e) {
    paste("Error calling Duke GPT:", e$message)
  })
}