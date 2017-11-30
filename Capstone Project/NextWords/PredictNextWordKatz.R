library(quanteda)
library(dplyr)

KatzBackOff <- function(testline){
  
  #Clean the string and tokenize
  tk = unlist(cleanTokens(testline))
  len <- length(tk)
  #Get Trigram starting with the input
  pattern = paste0(paste(tk[(len-1):len]),collapse = " ")
  triGroup <- getGramFound(pattern,trigram)
  
  if(nrow(triGroup)!=0){
    NextWords <- getNextWords(triGroup)
   if(nrow(NextWords)<100){
      leftOver <- getLeftOver(triGroup)
      pattern = tk[len]
      biGroup <-  getGramFound(pattern,bigram)
      if(nrow(biGroup)!=0){
        biUnobs <- getUnobs(biGroup,triGroup,leftOver)
        j <-100-nrow(NextWords)
        toAdd <- biUnobs[1:j,c("last_words","freq")]
        toAdd <-  toAdd[!is.na(toAdd$last_words),]
        NextWords <- rbind(NextWords,toAdd)
        if(nrow(NextWords)<100){
          UniUnobs <- getUnobs(unigram,triGroup,leftOver)
          j <-100-nrow(NextWords)
          toAdd <- UniUnobs[1:j,c("last_words","freq")]
          toAdd <-  toAdd[!is.na(toAdd$last_words),]
          NextWords <- rbind(NextWords,toAdd)
        }
        else{return(NextWords)}
      }
    }
    else{return(NextWords)}
  }
  
  else{
    pattern = tk[len]
    biGroup <-  getGramFound(pattern,bigram)
    if(nrow(biGroup)!=0){
      NextWords <- getNextWords(biGroup)
      if(nrow(NextWords)<100){
        leftOver <- getLeftOver(biGroup)
        UniUnobs <- getUnobs(unigram,biGroup,leftOver)
        j <-100-nrow(NextWords)
        toAdd <- UniUnobs[1:j,c("last_words","freq")]
        toAdd <-  toAdd[!is.na(toAdd$last_words),]
        NextWords <- rbind(NextWords,toAdd)
        return(NextWords)
      }
      else{return(NextWords)}
    }
    else{
      NextWords <- unigram[1:100,c("last_words","freq")]
      return(NextWords)
    }
  }
}

getGramFound <- function(pattern,gram){
  gramFound <- subset(gram,first_words == pattern)
  return(gramFound)
}

getNextWords<-function(gram){
  pred<- gram[1:100,c("last_words","freq")]
  pred <- pred[!is.na(pred$last_words),]
  return(pred)
}  
  
getLeftOver <- function(gram){
  return(1-sum(gram$Discount * gram$freq)/sum(gram$freq))
}

getUnobs <- function(gram1,gram2,leftOver){
  Unobs <- subset(gram1,!(gram1$last_words %in% gram2$last_words))
  Unobs <- mutate(gram1,Prob =(leftOver*(Discount*freq))/sum(Discount*freq))
  return(Unobs)
}

cleanTokens <- function(data){
  ###Remove non english characters
  data.cleaned<- iconv(data,"latin1","ASCII",sub="'")
  
  ###tokenize our dataset
  tk<- tokens(data.cleaned, what = "word", 
              remove_numbers = TRUE, remove_punct = TRUE,
              remove_symbols = TRUE, remove_hyphens = TRUE,
              remove_twitter = TRUE)
  
  tk <- tokens_tolower(tk)
  return(tk)
  
}

