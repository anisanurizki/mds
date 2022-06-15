##Library
library(dplyr)
library(rvest)
library(rtweet)
library(mongolite)

##Scraping Data
url  <- "https://harga-emas.org/1-gram/"

# gold
data <- url %>% read_html() %>% html_table
data <- data[[1]]
gold <- data[3:6,-c(3:4)]

##Menyimpan update data ke MongoDB Database
#Menyiapkan koneksi
connection_string = Sys.getenv("MONGODB_CONNECTION")

#harga gold
harga = mongo(
  collection = "Emas_24_Karat",
  db = "Harga_Emas",
  verbose = FALSE,
  options = ssl_options()
)
harga$insert(gold)

# Publish to Twitter
##Create Twitter token
indikator_token <- create_token(
  app = "anrizki",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

##Tweet Gold
gold_tweet <- paste0("Update Harga 1 Gram Emas 24 Karat",
                     "\n",
                     gold[4,2], " WIB",
                     "\n",
                     "\n",
                     "USD: $", gold[1,2],
                     "\n",
                     "IDR: Rp", gold[3,2],
                    "\n",
                    "\n",
                    "Sementara itu, KURS USD/IDR saat ini adalah Rp", gold[2,2],
                    "\n",
                    "\n",
                    "#gold #kurs #jewelry #update")

## Post the image to Twitter
post_tweet(status = gold_tweet, token = indikator_token)
