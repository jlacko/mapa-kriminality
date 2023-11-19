# vytvoří ze všech ze zipáků ve složce /src 1 soubor v project rootu
library(readr)
library(tidyr)
library(dplyr)
library(sf)
library(fs)

# zipáky jako vektor
zip_files <- dir_ls("./src/", glob = "*.zip") 

for (soubor in zip_files) {
   
   unzip(soubor, exdir = "./src")
   
} # / end for cyklus zipáků

# soubory s daty jako vektor - beru v potaz pouze csvčka s čísly v názvu
csv_files <- dir_ls("./src/", regex = "([0-9]+).csv$")

vysledek <- data.frame()

# wipe the slate clean = nechceme vkládat nová data do starých; raději přepsat nez riskovat konflikty
if(file.exists("mapa-kriminality.gpkg")) file.remove("mapa-kriminality.gpkg")

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
      
      # aby geopackage nebyla velká jak cyp nastavíme filtr - ať již na datum nebo typ zločinu...
      filter(date >= as.POSIXct("2022-01-01") & date < as.POSIXct("2022-02-01")) %>% 
      mutate(date = format(date, "%Y-%m-%d")) %>% # sqlite moc neumí datum jako číslo; text je bulletproof
      st_as_sf(coords = c("x", "y"), crs = 4326) # z obyčejného df na prostorový
   
   
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
               fid_column_name = "crime_id",
               quiet = T) 
      
      con <- DBI::dbConnect(RSQLite::SQLite(), "./mapa-kriminality.gpkg") 
      
      DBI::dbWriteTable(con, "crime_data", non_geo)
      
      DBI::dbDisconnect(con) 
   
      } else {
      
      # n + prvý záznam = přidat k existujícímu
      st_write(geodata, "mapa-kriminality.gpkg",
               layer = "spatial_data",
               fid_column_name = "crime_id",
               append = T, quiet = T)     
         
      con <- DBI::dbConnect(RSQLite::SQLite(), "./mapa-kriminality.gpkg")
         
      DBI::dbAppendTable(con, "crime_data", non_geo)
         
      DBI::dbDisconnect(con) 
         
   } # / end if file exits


}  # / end for cyklus tvorby geopackage

