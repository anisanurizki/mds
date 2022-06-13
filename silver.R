##Library
library(dplyr)
library(rvest)
library(rtweet)
library(mongolite)

##Scraping Data
url2 <- "https://harga-emas.org/perak/"

data2 <- url2 %>% read_html() %>% html_table
data2 <- data2[[1]]
View(data)

silver <- data2[c(4,6,8),-c(2,4,5)]

##Menyimpan update data ke MongoDB Database
#Menyiapkan koneksi
connection_string = Sys.getenv("MONGODB_CONNECTION")

#Markets
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

## 1st Hashtag
hashtag <- c("ManajemenData","ManajemenDataStatistika", "github","rvest","rtweet", "MongoDB", "bot", "opensource", "gold", "silver")

samp_word <- sample(hashtag, 3)

##Tweet
emas_tweet <- paste0("Update Harga 1 Gram Perak",
                     "\n",
                     silver[3,1],
                     "\n",
                     "\n",
                     "USD: ", silver[1,2],
                     "\n",
                     "IDR: ", silver[2,2],
                     "\n",
                     "\n",                 
                     "#",samp_word)

## Post the image to Twitter
post_tweet(status = emas_tweet, token = indikator_token)
