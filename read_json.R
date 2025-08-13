
############################################################
# 
#    READ JSON FILES
#
#    Author: Tie Franco Brotto
#    Date: 2025 August
#
############################################################

# Delete all objects in the environment (clean memory)
rm(list = ls())
# Prevent scientific notation i.e. using e powers
options(scipen = 999)
# Set working directory
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(jsonlite)
library(dplyr)
library(janitor)
library(tidyr)
library(stringr)
library(purrr)
library(tidyverse)


df <- fromJSON("firestore_export.json", flatten = TRUE) %>% 
  as_tibble() %>%
  select(session_id, data)
#df <- filter(df, session_id == "Q0FK1ymEMmi2PkJP53E2")
df2 <- df[[2]] # Select all participants' data

step1 <- function(data) {
  data <- as.data.frame(t(unlist(data$response))) # Flatten trial "responses"
  data <- data[, sort(colnames(data))] # Sort columns alphabetically (little redundant, but just to make sure the binding matches)
}

df3 <- map(df2, step1) # Apply the flattening function to all participants
responses <- bind_rows(df3) %>% # Combine everything into a dataframe
  mutate(across(everything(), as.numeric))

final <- df %>%
  select(session_id) %>%
  bind_cols(responses) %>%
  # mutate(across(everything(), as.numeric)) %>%
  mutate(across(starts_with("climate_palestine_"), 
                ~ ifelse(get(paste0("climate_palestine_", sub("climate_palestine_", "", cur_column()))) == 1, NA, .))) %>%
  mutate(across(starts_with("mod_rad_"), 
                ~ ifelse(get(paste0("climate_palestine_", sub("mod_rad_", "", cur_column()))) == 1, NA, .))) %>%
  mutate(across(starts_with("limited_broad_"), 
                ~ ifelse(get(paste0("climate_palestine_", sub("limited_broad_", "", cur_column()))) == 1, NA, .)))

# calc <- colMeans(final[-"session_id"], na.rm = TRUE)
calc <- colMeans(final[ , setdiff(names(final), "session_id")], na.rm = TRUE)

# Turn named vector into data frame
calc_df <- tibble(
  name = names(calc),
  value = as.numeric(calc)
) %>%
  # Extract index number and category
  mutate(
    post_index = as.numeric(str_extract(name, "\\d+$")),
    category = str_remove(name, "_\\d+$")
  ) %>%
  # Spread into wide format
  pivot_wider(
    id_cols = post_index,
    names_from = category,
    values_from = value
  ) %>%
  select(post_index, climate_palestine, mod_rad, limited_broad) %>%
  arrange(as.numeric(post_index))  # sort by index

result <- df2[[1]] %>%
  select(post_index, link, group) %>%
  full_join(calc_df, join_by(post_index))

write_csv(result, "pre-manipulation_results.csv")

# Recursive function to show structure without actual values
show_structure <- function(x, indent = 0) {
  pad <- paste(rep(" ", indent), collapse = "")
  
  if (is.list(x)) {
    if (!is.null(names(x))) {
      # Named list
      walk(names(x), ~ {
        cat(pad, .x, ":\n", sep = "")
        show_structure(x[[.x]], indent + 2)
      })
    } else {
      # Unnamed list
      cat(pad, "- list of", length(x), "items\n")
      if (length(x) > 0) show_structure(x[[1]], indent + 2)
    }
  } else {
    cat(pad, "-", class(x), "\n", sep = "")
  }
}

# Run it
show_structure(df)
