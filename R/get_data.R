library(magrittr)
library(stringr)
library(rvest)
library(dplyr)

getTablePage <- function(race, year, page) {
    url <- paste0("http://eu.ironman.com/triathlon/coverage/athlete-tracker.aspx?",
                  "race=", race,
                  "&y=",   year, 
                  "&p=",   page)
    tab <- read_html(url) %>%
        rvest::html_node(xpath = "//table") %>% 
        html_table()
    tab[,c(1,2,6,7,8,9)]
}


getNumPages <- function(race, year) {
    
    url <- paste0("http://eu.ironman.com/triathlon/coverage/athlete-tracker.aspx?",
                  "race=", race,
                  "&y=",   year, 
                  "&p=",   1)
    
    tmp <- read_html(url)
    n_athletes <- tmp %>% rvest::html_node(xpath = "//h2") %>% 
        as.character() %>% 
        stringr::str_extract_all("[0-9\\,]+") %>%
        extract2(1) %>%
        extract(2) %>%
        stringr::str_remove(",") %>%
        as.integer()
    
    n_pages <- (n_athletes %/% 20) + 1
    
    return(n_pages)
    
}

getResultsTable <- function(race, year) {
    
    n_pages <- getNumPages(race, year)
    
    pbapply::pblapply(seq_len(n_pages), getTablePage, race = race, year = year) %>%
        dplyr::bind_rows() %>%
        as_tibble()
    
}
