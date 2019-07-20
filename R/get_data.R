
#' @importFrom dplyr mutate_all
#' @importFrom rvest html_node html_table
#' @importFrom xml2 read_html
.getTablePage <- function(race, year, page) {
    url <- paste0("http://eu.ironman.com/triathlon/coverage/athlete-tracker.aspx?",
                  "race=", race,
                  "&y=",   year, 
                  "&p=",   page)
    tab <- xml2::read_html(url) %>%
        rvest::html_node(xpath = "//table") %>% 
        html_table() %>%
        mutate_all(as.character)
    
    return(tab)
}

#' @importFrom rvest html_node 
#' @importFrom xml2 read_html
#' @importFrom stringr str_extract_all str_remove
#' @import magrittr
.getNumPages <- function(race, year) {
    
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

#' @importFrom dplyr mutate
.classifyDNF <- function(results_table) {
    
    tmp <- results_table %>% 
        mutate(Status = ifelse((Status == "DNF" & is.na(Run)), "DNF - Run", Status)) %>%
        mutate(Status = ifelse((grepl("^DNF", Status) & is.na(Bike)), "DNF - Bike", Status))
    
    ## sometimes a swim is cancelled, so check before doing this
    if(!all(is.na(tmp$Swim))) {
        tmp <- tmp %>%
            mutate(Status = ifelse((grepl("^DNF", Status) & is.na(Swim)), "DNF - Swim", Status))
    } 
    
    res <- tmp %>%
        mutate(Status = factor(Status, 
                               levels = c("FINISHED", "DNF - Run", "DNF - Bike", "DNF - Swim", "DQ", "DNS")))
    
    return(res)
    
}

#' @importFrom dplyr bind_rows as_tibble arrange
#' @importFrom lubridate hms as.period
#' @importFrom pbapply pblapply
#' @export
getResultsTable <- function(race, year) {
    
    n_pages <- .getNumPages(race, year)
    
    full_tab <- pbapply::pblapply(seq_len(n_pages), .getTablePage, race = race, year = year) %>%
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
    
    full_tab <- .classifyDNF(full_tab) %>%
        arrange(Status, Finish)
    
    return(full_tab)
}
