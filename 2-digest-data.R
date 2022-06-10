# načte ze zipáků 1 soubor
library(readr)
library(tidyr)
library(dplyr)

zip_files <- fs::dir_ls("./src/", glob = "*.csv.zip") 

for (soubor in zip_files) {
   
   unzip(soubor, exdir = "./src")
   
}

# soubory s daty jako vektor
csv_files <- fs::dir_ls("./src/", regex = "([0-9]+).csv$") 

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

# one hot encoding typů zločinů
vysledek <- vysledek %>%                
   mutate(id = row_number(),                 
          value = TRUE) %>%                     
   separate_rows(types) %>%           
   pivot_wider(names_from = types, 
               names_prefix = 'type_',
               values_from = value, 
               values_fill = FALSE) %>% 
   select(-id)

saveRDS(vysledek, "./src/mapa.rds")