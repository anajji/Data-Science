setwd("d:/Profiles/anajji/Desktop/Learning/R/Data Science Capstone")

source("Process.R")
source("PredictNextWord.R")

setwd("d:/Profiles/anajji/Desktop/Learning/R/Data Science Capstone/final/en_US")

set.seed(1010)
p = 0.75

twitter <-readLines("en_US.twitter.txt", encoding="Latin-1")
news<-readLines("en_US.news.txt", encoding="Latin-1")
blogs<-readLines("en_US.blogs.txt", encoding="Latin-1")

twitter_sample <- data.frame(text=sample(twitter,length(twitter)*p), stringsAsFactors = FALSE)
news_sample <- data.frame(text=sample(news,length(news)*p), stringsAsFactors = FALSE)
blogs_sample <- data.frame(text=sample(blogs,length(blogs)*p), stringsAsFactors = FALSE)

rm(twitter,news,blogs)

data <- rbind(twitter_sample,news_sample,blogs_sample)
rm(twitter_sample,news_sample,blogs_sample)

tokens <- cleanTokens(data$text)
tokens <- removeProfanity(tokens)

unigram <-  termFrequency(tokens,1)
bigram <- termFrequency(tokens,2)
trigram <- termFrequency(tokens,3)

unigram <-transform(unigram,10)
bigram <- transform(bigram,10)
trigram <- transform(trigram,10)

bigram <- divideGram(bigram,2)
trigram <- divideGram(trigram,3)

nGramModel <- list(unigram,bigram,trigram)



