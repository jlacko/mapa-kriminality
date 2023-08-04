# Mapa kriminality - z API PČR přímo do vaší R Session

Cílem repa je:
- stahnout z API Policie české republiky zipáky s kriminalitou do složky `/src`
- stažené zipáky přeložit do jednoho geopackage souboru s názvem `mapa-kriminality.gpkg` pro další použití
- (optionally) využije faktu že gpkg je vlastně sqlite a tedy relační datbáze, a založí pomocné view `mapa_pracovni` nad vloženými daty, ale s připojenými číselníky zločinů + typologií míst + objasněnosti. Jedná se tedy o ty samá data, ale v uživatelsky přítulnějším formátu.
- that's it, to je všechno, víc to neumí :)

Big fat warning: zločinů je hodně, doběh (zejména části tvorby gpkg) je delší; buďto si omezte rozsah datumů, a/nebo skočte na kafe... Viz filter na [řádku 37](https://github.com/jlacko/mapa-kriminality/blob/main/2-digest-data.R#L37) v souboru `2-digest-data.R`.

Smaller technický warning: při stahování souborů z API PČR do `/src` (čiliže odpalování souboru `1-get-data.R`) může dojít na chybu 429 = too many requests před tím, než doběhnou data kompletně. Řešením je spuštění souboru s nevelkým časovým odstupem zopakovat.
