---
output:
  pdf_document: default
  html_document: default
---
# IRONMAN-Results
Download and process results tables from IRONMAN events


# Installation

```
remotes::install_github()
```

# Usage

Use the function `getResultsTable()` to download a complete set of results for an IRONMAN event.  This function takes two arguments, `race` and `year`, to specify the race you want to download.  The value for `race` should be the name IRONMAN use to refer to an event.  Sometimes this may be the name of a country e.g. 'Austria' and for other races it may be the name of a town e.g. 'Cork'.

```
austria_results <- getResultsTable(race = `Austria`, year = `2016`)
```

The result will be a `tibble` containing all information than can be retrieved from the IRONMAN website:

```
> austria
# A tibble: 2,866 x 13
   Name          Country `Div Rank` `Gender Rank` `Overall Rank` Swim       Bike       Run        Finish    Points Status  Race    Year
   <chr>         <chr>   <chr>      <chr>         <chr>          <Period>   <Period>   <Period>   <Period>  <chr>  <fct>   <chr>  <dbl>
 1 Borghs, Bart  BEL     10         19            20             1H 4M 51S  4H 48M 8S  2H 53M 29S 8H 52M 0S 4427   FINISH… austr…  2016
 2 Cullen, Tony  GBR     3          30            31             59M 53S    4H 40M 8S  3H 11M 5S  8H 57M 0S 4823   FINISH… austr…  2016
 3 Fouss, Franç… BEL     17         63            65             1H 0M 20S  4H 53M 49S 3H 11M 23S 9H 13M 0S 4580   FINISH… austr…  2016
 4 Bernhard, An… AUT     1          114           117            1H 11M 28S 4H 40M 17S 3H 26M 14S 9H 27M 0S 5000   FINISH… austr…  2016
 5 De Bilde, Jo… BEL     25         118           121            1H 0M 41S  4H 57M 24S 3H 23M 50S 9H 29M 0S 4383   FINISH… austr…  2016
 6 Kallio, Janne FIN     24         124           127            1H 0M 55S  4H 52M 46S 3H 29M 58S 9H 30M 0S 4427   FINISH… austr…  2016
 7 Härer, Chris… DEU     20         228           235            1H 2M 46S  4H 55M 36S 3H 42M 8S  9H 49M 0S 4352   FINISH… austr…  2016
 8 Williams, St… GBR     51         261           268            1H 7M 25S  5H 20M 35S 3H 16M 26S 9H 53M 0S 4151   FINISH… austr…  2016
 9 Westermann, … DEU     1          8             269            1H 11M 55S 5H 16M 19S 3H 16M 49S 9H 53M 0S 5000   FINISH… austr…  2016
10 Bognár, János HUN     69         262           270            1H 6M 17S  5H 5M 3S   3H 30M 50S 9H 53M 0S 4100   FINISH… austr…  2016
# … with 2,856 more rows
```

