# stahne surové zipáky do složky /src

library(dplyr)
library(curl)

# kartézáček let a měsíců - dle potřeby...
remotes <- expand.grid(year = 2012:2022, month = 1:12) %>% 
   mutate(date = ISOdate(year, month, '01')) %>% 
   mutate(text = format(date, "%Y%m")) %>% 
   pull(text)
   

# cesta v logice API
remotes <- paste0(
   "https://kriminalita.policie.cz/api/v2/downloads/",
   remotes,
   ".zip"
)

# stahnout ty co chybí... na konci to spadne na 404, ale to neva jsme na konci
for (remote in remotes) {
   if(!file.exists(file.path("./src", basename(remote)))){
      curl_download(url = remote, 
                    destfile = file.path("./src", basename(remote)))
   }
}

