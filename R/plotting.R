

## finishing times
#ggplot(full_tab, aes(x = as.numeric(Finish))) + 
#    geom_histogram(binwidth = 300) + 
#    scale_x_time()

#' @importFrom dplyr group_by summarise mutate
#' @importFrom forcats fct_relevel
#' @import ggplot2
#' @export
plotDropOutRate <- function(results_table) {
    
    tab <- results_table %>% 
        group_by(Status) %>% 
        summarise(count = n()) %>% 
        mutate(percentage = 100 * (count / sum(count))) %>%
        mutate(Status = fct_relevel(Status, "DNS", "DNF - Swim", "DNF - Bike", "DNF - Run", "FINISHED", "DQ"))
        
    
    ggplot(tab, aes(x = Status, y = percentage)) + 
        geom_bar(stat = "identity", fill = "skyblue") +
        theme_bw()
}

.plotLeg <- function(results_table, leg = "Finish") {
    
    ggplot(results_table %>% 
               filter( !is.na( .data[[leg]] ) ),
           aes_(x = as.name(leg))) +
        geom_density(fill = "skyblue") +
        scale_x_time() + 
        theme_classic()
    
}

plotSwimTimes <- function(results_table) {
    .plotLeg(results_table, leg = "Swim")
}
plotBikeTimes <- function(results_table) {
    .plotLeg(results_table, leg = "Bike")
}
plotRunTimes <- function(results_table) {
    .plotLeg(results_table, leg = "Run")
}
plotFinishTimes <- function(results_table) {
    .plotLeg(results_table, leg = "Finish")
}



#ggplot(results_table %>% 
    #        filter( !is.na( .data[[leg]] ) ),
    #    aes_(x = as.name(leg))) +
    # geom_histogram(binwidth = 600, fill = "skyblue") +
    # scale_x_time() + 
    # theme_classic() 
