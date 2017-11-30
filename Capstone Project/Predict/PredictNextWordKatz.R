setwd("d:/Profiles/anajji/Desktop/Learning/R/Data Science Capstone")
source("Process.R")

KatzBackOff <- function(testline){
  
  #Clean the string and tokenize
  tk = unlist(cleanTokens(testline))
  len <- length(tk)
  #Get Trigram starting with the input
  pattern = paste0(paste(tk[(len-1):len]),collapse = " ")
  triGroup <- getGramFound(pattern,trigram)
  
  if(nrow(triGroup)!=0){
    NextWords <- getNextWords(triGroup)
   if(length(NextWords)<3){
      leftOver <- getLeftOver(triGroup)
      pattern = tk[len]
      biGroup <-  getGramFound(pattern,bigram)
      if(nrow(biGroup)!=0){
        biUnobs <- getUnobs(biGroup,triGroup)
        j <-3-length(NextWords)
        toAdd <- biUnobs[1:j,"last_words"]
        NextWords <- c(NextWords,toAdd)
        if(length(NextWords)<3){
          uniUnobs <- getUnobs(unigram,triGroup)
          j <-3-length(NextWords)
          toAdd <- UniUnobs[1:j,"last_words"]
          NextWords <- c(NextWords,toAdd)
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
      if(length(NextWords)<3){
        leftOver <- getLeftOver(biGroup)
        UniUnobs <- getUnobs(unigram,biGroup)
        j <-3-length(NextWords)
        toAdd <- UniUnobs[1:j,"last_words"]
        NextWords <- c(NextWords,toAdd)
        return(NextWords)
      }
      else{return(NextWords)}
    }
    else{
      NextWords <- unigram[1:3,"last_words"]
      return(NextWords)
    }
  }
}

getGramFound <- function(pattern,gram){
  gramFound <- subset(gram,first_words == pattern)
  return(gramFound)
}

getNextWords<-function(gram){
  pred<- gram[1:3,"last_words"]
  pred <- pred[!is.na(pred)]
  return(pred)
}  
  
getLeftOver <- function(gram){
  return(1-sum(gram$Discount * gram$freq)/sum(gram$freq))
}

getUnobs <- function(gram1,gram2){
  Unobs <- subset(gram1,!(gram1$last_words %in% gram2$last_words))
  Unobs <- mutate(gram1,Prob =(leftOver*(Discount*freq))/sum(Discount*freq))
  return(Unobs)
}



