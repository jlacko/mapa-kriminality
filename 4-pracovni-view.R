# doplní do databáze pracovní view
# that's it, tečka :)

library(dplyr)
library(DBI)
library(RSQLite)

ddl_mapa_pracovni <- "CREATE VIEW mapa_pracovni AS 
                              select
                              	mk.crime_id ,
                              	mk.date ,
                              	s.label state,
                              	r.label relevance,
                              	t.name nazev_cinu,
                              	t.label popisek_cinu,
                              	mk.geom 
                              from 
                              	mapa_kriminality mk 
                              	inner join relevance r 
                              		on mk.relevance = r.id 
                              	inner join states s 
                              		on mk.state = s.id 
                              	inner join types t 
                              		on mk.types = t.id 
                            ;"



con <- DBI::dbConnect(RSQLite::SQLite(), "./mapa_kriminality.gpkg") # připojit databázi

# zahodit co bylo...
dbExecute(con, "drop view if exists mapa_pracovni;")

# vytvořit nové, čisté view nad vším
dbExecute(con, ddl_mapa_pracovni)

# zprovoznit gpkg
dbExecute(con, 
          "insert into gpkg_contents
           select
            'mapa_pracovni' table_name,
            mk.data_type,
            'mapa_pracovni' identifier,
            '' description,
            mk.last_change,
            mk.min_x,
            mk.min_y,
            mk.max_x,
            mk.max_y,
            mk.srs_id
          from (
            select *
            from gpkg_contents goc 
            where table_name = 'mapa_kriminality') mk
          ;")


dbExecute(con, 
          "insert into gpkg_geometry_columns
          values('mapa_pracovni', 'geom', 'POINT', '4326', 0, 0)
          ;
          ")


DBI::dbDisconnect(con) # poslední zhasne...