library(magrittr)
library(stringr)
library(rvest)
library(dplyr)
library(lubridate)

getTablePage <- function(race, year, page) {
    url <- paste0("http://eu.ironman.com/triathlon/coverage/athlete-tracker.aspx?",
                  "race=", race,
                  "&y=",   year, 
                  "&p=",   page)
    tab <- read_html(url) %>%
        rvest::html_node(xpath = "//table") %>% 
        html_table() %>%
        mutate_all(as.character)
    
    tab
}


getNumPages <- function(race, year) {
    
    url <- paste0("http://eu.ironman.com/triathlon/coverage/athlete-tracker.aspx?",
                  "race=", race,
                  "&y=",   year, 
                  "&p=",   1)
    
    tmp <- read_html(url)
    
    if(is.na( rvest::html_node(tmp, xpath = "//table") )) {
        stop("Results table not found")
    } else {
        n_athletes <- tmp %>% 
            rvest::html_node(xpath = "//h2") %>% 
            as.character() %>% 
            stringr::str_extract_all("[0-9\\,]+") %>%
            magrittr::extract2(1) %>%
            magrittr::extract(2) %>%
            stringr::str_remove(",") %>%
            as.integer()
        
        n_pages <- (n_athletes %/% 20) + 1
        
        return(n_pages)
    }
    
}

getResultsTable <- function(race, year) {
    
    n_pages <- getNumPages(race, year)
    
    full_tab <- pbapply::pblapply(seq_len(n_pages), getTablePage, race = race, year = year) %>%
        dplyr::bind_rows() %>%
        as_tibble() %>%
        mutate(Status = ifelse(grepl("^[0-9]", Finish), yes = "FINISHED", no = Finish),
               Race = race,
               Year = year)
    
    ## suppress warnings as many entries are "---"
    suppressWarnings(
        full_tab <- full_tab %>% 
            mutate(Swim = as.period(hms(Swim)), 
                   Bike = as.period(hms(Bike)),
                   Run = as.period(hms(Run)), 
                   Finish = as.period(hms(Finish))) 
    )
    
    full_tab <- classifyDNF(full_tab) %>%
        arrange(Status, Finish)
}
