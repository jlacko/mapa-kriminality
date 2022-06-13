# vytvoří ze všech ze zipáků ve složce /src 1 soubor v project rootu
library(readr)
library(tidyr)
library(dplyr)
library(fs)

# zipáky jako vektor
zip_files <- dir_ls("./src/", glob = "*.csv.zip") 

for (soubor in zip_files) {
   
   unzip(soubor, exdir = "./src")
   
}

# soubory s daty jako vektor
csv_files <- dir_ls("./src/", regex = "([0-9]+).csv$") 

vysledek <- data.frame()

# načíst všechny soubory do jednoho
for (soubor in csv_files) {
   
   vysledek <- vysledek %>% 
      rbind(read_csv(soubor,
                     col_types = cols(id = col_integer(),
                                      x = col_double(),
                                      y = col_double(), 
                                      mp = col_logical(),
                                      state = col_character(),
                                      types = col_character())))
   
}

# one hot encoding typů zločinů / formát types není zcela šťastný...
vysledek <- vysledek %>%
   rename(crime_id = id) %>% # prostý název id je zranitelný, crime_id bezpečnější
   mutate(id = row_number(),                 
          value = TRUE) %>%                     
   separate_rows(types) %>%           
   pivot_wider(names_from = types, 
               names_prefix = 'type_',
               values_from = value, 
               values_fill = FALSE) %>% 
   select(-id)

saveRDS(vysledek, "mapa-kriminality.rds")