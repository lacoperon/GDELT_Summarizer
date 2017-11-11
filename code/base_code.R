library(httr)
library(XML)
library(tm)
library(plyr)

### this is the URL
url1 = 'https://api.gdeltproject.org/api/v2/doc/doc?query=(teen OR teenager OR child OR toddler OR boy OR girl OR "-year-old") (accidentally OR unintentionally) (shot OR killed OR wounded OR fired) (weapon OR gun OR shotgun OR rifle OR pistol) sourceCountry:US&mode=artlist&maxrecords=250&format=CSV&TIMESPAN=3d'

url = URLencode(url1)
s = GET(url)

df = read.csv(text = httr::content(s, as="text"), stringsAsFactors = F, header=T)
colnames(df) = c("URL", "MobileURL", "Date", "Title")


k = grepl("(?<=http://www.).*?(?=.com)", df$URL, perl=T, ignore.case=T)
m = regexpr("(?<=http://www.).*?(?=.com)", df$URL[k], perl=T, ignore.case=T)
t = regmatches(df$URL[k], m)

df2 = df[k, ]
df2$domain = toupper(t)

r = df2$domain %in% short_stations$UniqueIdentifier
df2 = df2[r, ]

tv_story = merge(x = df2, 
                 y = short_stations[ , c("UniqueIdentifier", "StationName", "Location")],
                 by.x="domain", by.y="UniqueIdentifier")

