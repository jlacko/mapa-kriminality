# stahne surové zipáky do složky /src

library(dplyr)
library(curl)

# kartézáček let a měsíců - dle potřeby...
remotes <- expand.grid(year = 2012:(as.POSIXlt(Sys.Date())$year + 1900), month = 1:12) %>%
   # vykosit budoucnost - rok běžný a měsíc vyšší nebo roven běžnému 
   filter(!(year == (as.POSIXlt(Sys.Date())$year + 1900)
          & month >= as.POSIXlt(Sys.Date())$mon + 1)) %>% 
   mutate(date = ISOdate(year, month, '01')) %>% 
   mutate(text = format(date, "%Y%m")) %>% 
   pull(text)
   

# cesta v logice API
remotes <- paste0(
   "https://kriminalita.policie.cz/api/v2/downloads/",
   remotes,
   ".zip"
)

# stahnout ty co chybí, ale na zdroji existují...
for (remote in remotes) {
   if(!file.exists(file.path("./src", basename(remote)))) # lokálně chybí...
      {
      curl_download(url = remote, 
                    destfile = file.path("./src", basename(remote)))
   }
}

