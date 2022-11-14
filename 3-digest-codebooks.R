# doplní do databáze doplňující číselníky
# that's it, tečka :)

library(dplyr)
library(DBI)
library(RSQLite)

ddl_relevance <- "CREATE TABLE relevance (
                  id INT,
                  label TEXT
              );"

ddl_states <- "CREATE TABLE states (
                  id INT,
                  label TEXT
              );"

ddl_types <- "CREATE TABLE types (
                      id INT,
                      parent_id1 INT,
                      parent_id2 INT,
                      parent_id3 INT,
                      name TEXT,
                      label TEXT
                  );"

con <- DBI::dbConnect(RSQLite::SQLite(), "./mapa_kriminality.gpkg") # připojit databázi

# zahodit co bylo...
dbExecute(con, "drop table if exists relevance;")
dbExecute(con, "drop table if exists states;")
dbExecute(con, "drop table if exists types;")

# vytvořit novou, čistou tabulku relevance
dbExecute(con, ddl_relevance)

# načíst z csvčka - editace vedle v Excelu!!
relevance <- readr::read_csv("./src/relevance.csv")

# uložit do databáze
DBI::dbAppendTable(con, "relevance", relevance)

# vytvořit novou, čistou tabulku stavů
dbExecute(con, ddl_states)

# načíst z csvčka - editace vedle v Excelu!!
states <- readr::read_csv("./src/states.csv")

# uložit do databáze
DBI::dbAppendTable(con, "states", states)

# vytvořit novou, čistou tabulku typů
dbExecute(con, ddl_types)

# načíst z csvčka - editace vedle v Excelu!!
types <- readr::read_csv("./src/types.csv")

# uložit do databáze
DBI::dbAppendTable(con, "types", types)


DBI::dbDisconnect(con) # poslední zhasne...