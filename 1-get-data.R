# stahne surové zipáky do složky /src

library(dplyr)
library(fs)

# kartézáček let a měsíců
remotes <- expand.grid(year = 2012:2022, month = 1:12) %>% 
   mutate(date = ISOdate(year, month, '01')) %>% 
   mutate(text = format(date, "%Y%m")) %>% 
   pull(text)
   

# cesta v logice API
remotes <- paste0(
   "https://kriminalita.policie.cz/api/v1/downloads/",
   remotes,
   ".csv.zip"
)

# stahnout ty co chybí... na konci to spadne na 404, ale to neva jsme na konci
for (remote in remotes) {
   if(!file.exists(basename(remote))) curl::curl_download(
      url = remote,
      destfile = file.path("./src", basename(remote))
   )
}

