##Library
library(dplyr)
library(rvest)
library(rtweet)
library(mongolite)

##Scraping Data
url2 <- "https://harga-emas.org/perak/"

#silver
data2  <- url2 %>% read_html() %>% html_table
data2  <- data2[[1]]
silver <- data2[3:8,-c(4:5)]

##Menyimpan update data ke MongoDB Database
#Menyiapkan koneksi
connection_string = Sys.getenv("MONGODB_CONNECTION")

#harga silver
harga2 = mongo(
  collection = "Silver",
  db = "Harga",
  verbose = FALSE,
  options = ssl_options()
)
harga2$insert(silver)

# Publish to Twitter
##Create Twitter token
indikator_token <- create_token(
  app = "anrizki",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

##Tweet Silver
silver_tweet <- paste0("Update Harga Perak",
                       "\n",
                       silver[6,1],  " WIB",
                       "\n",
                       "\n",
                       "Per 1 Gram",
                       "\n",
                       "USD: $", silver[2,3],
                       "\n",
                       "IDR: Rp", silver[4,3],
                      "\n",
                       "\n",
                       "Per 1 Ons",
                       "\n",
                       "USD: $", silver[1,3],
                       "\n",
                       "IDR: Rp", silver[3,3],
                       "\n",
                       "\n",
                       "#silver #jewelry #update")

post_tweet(status = silver_tweet, token = indikator_token)
