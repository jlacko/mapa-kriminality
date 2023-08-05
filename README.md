# Mapa kriminality - z API PČR přímo do vaší R Session

Cílem repa je:
- stahnout z API Policie české republiky zipáky s kriminalitou do složky `/src`
- stažené zipáky přeložit do jednoho geopackage souboru s názvem `mapa-kriminality.gpkg` pro další použití
- (optionally) využije faktu že gpkg je vlastně sqlite a tedy relační datbáze, a založí pomocné view `mapa_pracovni` nad vloženými daty, ale s připojenými číselníky zločinů + typologií míst + objasněnosti. Jedná se tedy o ty samá data, ale v uživatelsky přítulnějším formátu.
- that's it, to je všechno, víc to neumí :)

Big fat warning: zločinů je hodně, doběh (zejména části tvorby gpkg) je delší; buďto si omezte rozsah datumů, a/nebo skočte na kafe... Viz filter na [řádku 37](https://github.com/jlacko/mapa-kriminality/blob/main/2-digest-data.R#L37) v souboru `2-digest-data.R`.

Smaller technický warning: při stahování souborů z API PČR do `/src` (čiliže odpalování souboru `1-get-data.R`) může dojít na chybu 429 = too many requests před tím, než doběhnou data kompletně. Řešením je spuštění souboru s nevelkým časovým odstupem zopakovat.

## Příklad využití v praxi

Protože ukázka je více jak 1000 slov: krátká ukázka kódu + vizualizace

```r
library(sf)
library(ggplot2)
library(RCzechia)

besip <- st_read(dsn = "mapa-kriminality.gpkg",
                 query = "select * from mapa_pracovni where popisek_cinu like '%BESIP%';")

# přehled dle data...
besip %>% 
   st_drop_geometry() %>%  
   group_by(date) %>% 
   tally() %>% 
   arrange(desc(n))
   
#  A tibble: 10 × 2
#    date           n
#    <chr>      <int>
#  1 2021-12-31    13
#  2 2022-01-01  1618
#  3 2022-01-02  2667
#  4 2022-01-03  3964
#  5 2022-01-04  4251
#  6 2022-01-05  4889
#  7 2022-01-06  5005
#  8 2022-01-07  5058
#  9 2022-01-08  3824
# 10 2022-01-09  3732

# jednoduchá vizualizace / najdi si svojí dálnici...
ggplot() +
   geom_sf(data = besip, color = "red", pch = 4, alpha = 1/3, size = 1) +
   geom_sf(data = republika(), fill = NA, lwd = 1) +
   labs(title = "Přestupky proti bezpečnosti silničního provozu",
        subtitle = "za měsíc leden 2022",
        caption = "původ zdrojových dat: Policie České republiky")
```
<p align="center">
  <img src="https://github.com/jlacko/mapa-kriminality/blob/main/besip-mapa.png?raw=true" alt="přestupky proti BESIP v mapě ČR"/>
</p>
