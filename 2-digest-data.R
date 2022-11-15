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

# soubory s daty jako vektor - beru v potaz pouze csvčka s čísly v názvu
csv_files <- dir_ls("./src/", regex = "([0-9]+).csv$")

# pro zjednodušení pouze letošní Q1 - Q3
csv_files <- csv_files[stringr::str_detect(csv_files, pattern = "20220")]

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
   
   
   geodata <- vysledek %>% 
      select(crime_id) %>% 
      unique()
   
   non_geo <- vysledek %>% 
      st_drop_geometry()
   
   
   if(!file.exists("mapa-kriminality.gpkg")){
      
      # první záznam = založit soubor
      st_write(geodata,
               dsn = "mapa-kriminality.gpkg",
               layer = "spatial_data",
               quiet = T)     
      st_write(non_geo, "mapa-kriminality.gpkg",
               layer = "crime_data",
               quiet = T)
   
      } else {
      
      # n + prvý záznam = přidat k existujícímu
      st_write(geodata, "mapa-kriminality.gpkg",
               layer = "spatial_data",
               append = T, quiet = T)     
      st_write(non_geo, "mapa-kriminality.gpkg",
               layer = "crime_data",
               append = T, quiet = T)
         
   } # / end if file exits


}  # / end for cyklus tvorby geopackage

