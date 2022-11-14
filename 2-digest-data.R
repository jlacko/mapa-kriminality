# vytvoří ze všech ze zipáků ve složce /src 1 soubor v project rootu
library(readr)
library(tidyr)
library(dplyr)
library(sf)
library(fs)

# zipáky jako vektor
zip_files <- dir_ls("./src/", glob = "*.csv.zip") 

for (soubor in zip_files) {
   
   unzip(soubor, exdir = "./src")
   
} # / end for cyklus zipáků

# soubory s daty jako vektor
csv_files <- dir_ls("./src/", regex = "([0-9]+).csv$") 

vysledek <- data.frame()

# načíst všechny soubory do jednoho
for (soubor in csv_files) {
   
   vysledek <- read_csv(soubor,
                        col_types = cols(id = col_integer(),
                                         x = col_double(),
                                         y = col_double(),
                                         mp = col_logical(),
                                         date = col_datetime(),
                                         state = col_integer(),
                                         relevance = col_integer(),
                                         types = col_integer())) %>% 
      rename(crime_id = id) %>%   # prostý název id je zranitelný, crime_id bezpečnější
      st_as_sf(coords = c("x", "y"), crs = 4326)
   
   if(!file.exists("mapa_kriminality.gpkg")){
      
      # první záznam = založit soubor
      st_write(vysledek, "mapa_kriminality.gpkg")
   
      } else {
      
      # n + prvý záznam = přidat k existujícímu
      st_write(vysledek, "mapa_kriminality.gpkg", append = TRUE, quiet = TRUE)
         
   } # / end if file exits


}  # / end for cyklus tvorby geopackage

