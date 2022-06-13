##Library
library(dplyr)
library(rvest)
library(rtweet)
library(mongolite)

##Scraping Data
url <- "https://harga-emas.org/1-gram/"
emas <- read_html(url)
data <- url %>% read_html() %>% html_table
data <- data[[1]]
View(data)

emas <- data[3:6,-c(3:4)]

##Menyimpan update data ke MongoDB Database
#Menyiapkan koneksi
connection_string = Sys.getenv("MONGODB_CONNECTION")

#Markets
harga = mongo(
  collection = "Emas_24_Karat",
  db = "Harga_Emas",
  verbose = FALSE,
  options = ssl_options()
)
harga$insert(emas)


# Publish to Twitter
##Create Twitter token
indikator_token1 <- create_token(
  app = "anrizki",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

##Tweet
emas_tweet <- paste0("Update Harga 1 Gram Emas 24 Karat",
                     "\n",
                     data[6,2],
                     "\n",
                     "\n",
                     "USD: ", data[3,2],
                     "\n",
                     "IDR: ", data[5,2],
                     "\n",
                     "\n",
                     "Sementara itu, KURS USD ke IDR saat ini adalah ", data[4,2])

## Post the image to Twitter
post_tweet(status = emas_tweet, token = indikator_token1)
