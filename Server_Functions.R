
# Functions for Server






check_UNKNOWNTOKEN <- function(string) {
  
  for(i in 1:length(string)){
    if(is.null(dic[[string[i]]])){
      string[i] <- "UNKNOWNTOKEN"
    }else(string[i] <- string[i])
  }
  
  return(string)
}


preprocess_string <- function(string){
  check_UNKNOWNTOKEN(
    unlist(
      str_extract_all(
        str_c("BEGIN ",string), "[:punct:]|[:alpha:]+|[:digit:]|[:graph:]|[^[:blank:]]"
        )
      )
    )
}

end_sentence_check <- function(string){
  string <- stri_replace_all_fixed(string,
                                   end_string, 
                                   c(stri_c(". END", writing_style, " BEGIN"),  
                                     stri_c("! END", writing_style, " BEGIN"), 
                                     stri_c("? END", writing_style, " BEGIN")), 
                         vectorize_all=FALSE)
  
  return(string)
  }

run_model <- function(text_string){
  
  for(i in length(text_string)){
    RNN <- mx.lstm.forward(infer.model,dic[[text_string[i]]]-1, F)
    infer.model <- RNN$model 
    
    DT <- data.table::as.data.table(as.array(RNN$prob))
    DT[, V2 := as.integer(rownames(DT))]
    DT[, V3 := lookup.table[[V2]], by = V2]
    DT <- dplyr::arrange(DT, desc(V1))
  }
  
  return(list(infer.model = infer.model, DT = DT))
}


reduce_chr_vector <- function(tokens, check_box = T, to_auto = T){
  
  x <- unlist(lapply(1:5, function(z)
    which(tokens$V3 == remove[z] )))
  
  
  if(is.null(check_box)){
    check_box <- T
  }else(check_box = check_box)
  
  
  if(check_box){
    
    x2 <- unlist(lapply(1:length(easterEgg.BadWorder), function(i)
      which(tokens$V3 == easterEgg.BadWorder[i])))
    
    if(!is.null(x) && !is.null(x2) && length(x) != 0 && length(x2) != 0 ){
      tokens <- tokens[-c(x,x2),]
      }else{if(!is.null(x2) && length(x2) != 0 && length(x) == 0){
        tokens <- tokens[-c(x2),]
        }else{if(!is.null(x) && length(x) != 0){
          tokens <- tokens[-c(x),]
        }else(tokens=tokens)
        }
      }
    }
  
  
    
    if(check_box == F && !is.null(x) && length(x) != 0 ){
      tokens <- tokens[-c(x),]
    }else(tokens=tokens)
  
  
  if(nrow(tokens) > 5 && to_auto){
    tokens <- tokens[1:5, ]
  }else(tokens=tokens)
  
  return(tokens=tokens)
  
}





key_events_search <- c(8, 37:40, 46:90,106:111, 186:192, 219:222)

Special_Characters <- c(":", "?", "+", ")", "(", "[", "]", "{", "}", "\\")

remove <- c("BEGIN", "ENDBLOG", "ENDTWITTER", "ENDNEWS", "UNKNOWNTOKEN")

end_string <- c(".", "?", "!")

