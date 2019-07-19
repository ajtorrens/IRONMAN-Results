library(ggplot2)

## finishing times
ggplot(full_tab, aes(x = as.numeric(Finish))) + 
    geom_histogram(binwidth = 300) + 
    scale_x_time()


plotDropOutRate <- function(results_table) {
    
    tab <- results_table %>% 
        group_by(Status) %>% 
        summarise(count = n()) %>% 
        mutate(percentage = 100 * (count / sum(count))) %>%
        mutate(Status = fct_relevel(Status, "DNS", "DNF - Swim", "DNF - Bike", "DNF - Run", "FINISHED", "DQ"))
        
    
    ggplot(tab, aes(x = Status, y = percentage)) + 
        geom_bar(stat = "identity") +
        theme_bw()
}

classifyDNF <- function(results_table) {
    
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
