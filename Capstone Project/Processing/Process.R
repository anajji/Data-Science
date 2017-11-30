
library(quanteda)
library(doSNOW)
library(parallel)
library(Kmisc)
library(qdap)
library(dplyr)


### Create tokens from documents and remove Numbers, Punctuation, Symbols and Hyphens. Lower also all the tokens.

cleanTokens <- function(data){
  ###Create a cluster 
  ncores <- detectCores() - 1
  cl <- makeCluster(ncores)
  registerDoSNOW(cl)
  
  ###Remove non english characters
  data.cleaned<- iconv(data,"latin1","ASCII",sub="'")
  
  ###tokenize our dataset
  tk<- tokens(data.cleaned, what = "word", 
                     remove_numbers = TRUE, remove_punct = TRUE,
                     remove_symbols = TRUE, remove_hyphens = TRUE,
                     remove_twitter = TRUE)
  
  tk <- tokens_tolower(tk)
  
  stopCluster(cl)
  
  return(tk)
  
}


removeProfanity <- function(token){
  
  ###Download the profanity file
  
  url<-"https://raw.githubusercontent.com/LDNOOBW/List-of-Dirty-Naughty-Obscene-and-Otherwise-Bad-Words/master/en"
  
  FileName <- "profanity.txt"
  if (!file.exists(FileName)) {
    download.file(url, destfile = FileName, method = "curl")
  }
  profanity <- as.vector(head(read.csv(FileName,header = FALSE, stringsAsFactors = FALSE),-1))
  
  
  ### Process the profanity words in parallel
  ###Create a cluster
  ncores <- detectCores() - 1
  cl <- makeCluster(ncores)
  registerDoSNOW(cl)
  
  ###Remove words from the tokens
  token <- tokens_select(token, profanity$V1, 
                           selection = "remove")
  
  stopCluster(cl)
  
  return(token)
}

termFrequency <- function(token,N){
  
  ###Create a cluster 
  ncores <- detectCores() - 1
  cl <- makeCluster(ncores)
  registerDoSNOW(cl)
  
  ###Create the ngrams
  ngram <- tokens_ngrams(token, n =N,concatenator = " ")
  ngram <-dfm(ngram)
  ###order the words by occurence
  top <- topfeatures(ngram,n=nfeature(ngram), decreasing = TRUE)
  ###create the data frame
  top <- droplevels(data.frame(last_words=names(top),freq=unname(top),stringsAsFactors = FALSE))
  stopCluster(cl)
  
  return(top)

}

transform <- function(gram,p){
  ncores <- detectCores() - 1
  cl <- makeCluster(ncores)
  registerDoSNOW(cl)
  
  ###Take the most important words
  gram <- gram[gram$freq>p,]
  
  gram$Discount <- rep(1, nrow(gram))
  for(i in (p+1):(p+5)){
    curr = nrow(subset(gram,gram$freq==i))
    nextr = nrow(subset(gram,gram$freq==i+1))
    disc <- ((i+1)/i)*(nextr/curr)
    gram[gram$freq==i,"Discount"]<-disc
  }
  stopCluster(cl)
  
  return(gram)
  
}

divideGram <- function(gram,ngram){
  first_words <- beg2char(gram$last_words, " ", ngram-1)
  last_words <- char2end(gram$last_words, " ",  ngram-1)
  gram$first_words <- first_words
  gram$last_words <- last_words
  gram <- gram[,c("first_words","last_words","freq","Discount")]
}

