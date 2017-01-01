
# Neural Network Word Prediction
# LSTM RNN 
# Long short-term memory recurrent neural network


gc()
gc()


require(shiny)
require(mxnet)
require(data.table)
require(stringi)
require(stringr)
require(jsonlite)


# keep words/tokens in character format
options(stringsAsFactors = F)

# Load data from pre-trained RNN-LSTM model
# This will be fed into lstm.interface
new_args <- mx.nd.load("new_args")

# Load data for the word filter
# from https://gist.github.com/jamiew/1112488
easterEgg.BadWorder <- fromJSON("easterEgg.BadWorder")

# Load known tokens includes words and characters
dic <- fromJSON("dic.json")
# Load look up key for dictionary
lookup.table  <- as.list(fromJSON("lookup.table.json"))

# number of tokens in dictionary
vocab_length <- length(dic)

# hyperparameter tuning for RNN-LSTM interface model
#batch.size = 64
#seq.len = 64
num_hidden = 800
num_embed = 800
num.lstm.layer = 2
#num.round = 25
#learning.rate= 0.1
#wd=0.0001
#clip_gradient= 1
#update.period = 1


# Run helper functions from file
source("Server_Functions.R", local = T)




infer.model <- mx.lstm.inference(num.lstm.layer,
                                 input.size=vocab_length,
                                 num.hidden=num_hidden,
                                 num.embed=num_embed,
                                 num.label=vocab_length,
                                 arg.params=new_args,
                                 ctx=mx.cpu(),
                                 dropout = 0)



# Pre-run blank string to prime model 
# The function preprocess_string extracts and separates tokens then adds "BEGIN" token 
# The function run_model runs all tokens through a feed-forward network & reorders a table pertaining to the likeliness of the next token
Predict_words <- run_model(preprocess_string(""))

# Update the infer.model
infer.model <- Predict_words$infer.model


writing_style <- NULL



shinyServer(function(input, output, session) {
  
  
  datasetInput <- reactive({
    
    
    # mydata & mydata2 feed keydown and keypress values from index.html to the shinyServer
    if(is.null(input$mydata)){
      
      Predict_words$DT
      
      # Runs model when space or enter is pressed on the keyboard
    }else{if(!is.null(input$mydata2) && input$mydata2 == 32 | input$mydata == 13 | input$mydata  == 9 | input$mydata == 1){
      
      Predict_words <<- run_model( preprocess_string(end_sentence_check(input$tokens)))
      infer.model <<- Predict_words$infer.model
      Predict_words$DT
      
     
      # Watch for character, punctuation, numeric, and backspace keyboard events
    }else{if(any(input$mydata2 == key_events_search, na.rm = T)){
      
      last_token <- last(unlist(str_extract_all(input$tokens, "[:punct:]|[:alpha:]+|[:digit:]|[:graph:]|[^[:blank:]]")))
      
      if(any(last_token==Special_Characters)){
         # Performs fixed search while typing punctuation
        Predict_words$DT[which(!is.na(str_locate(Predict_words$DT$V3 ,fixed(last_token)))[,1]),]
      }else(# Performs regex search while typing word or phrase
        Predict_words$DT[which(!is.na(str_locate(Predict_words$DT$V3 ,regex(stri_c("^", last_token)))[,1])),]
      )
      # return sorted data table
    }else(Predict_words$DT = Predict_words$DT)
    }
    }
  })
  
  
  
  
  
  observe({
    
    # Send up to 5 most likely tokens to jquery autocomplete function 
    # (if input$aBadword == T) filter words
      session$sendCustomMessage(type = "for_autocomplet2", 
                                reduce_chr_vector(datasetInput(), input$aBadword, to_auto = T)[,3])
    
    
    # Send up to 50 most likely tokens to d3.js Word Cloud function
    # (if input$aBadword == T) filter words
    session$sendCustomMessage(type = "for_WordCloud", 
                              toJSON(as.data.frame(reduce_chr_vector(datasetInput(), input$aBadword, to_auto = F)[1:50,])))
    
   
    # create a three row data table in descending order of likeliness
    writing_style <<- dplyr::filter(Predict_words$DT, V3 == "ENDBLOG" | V3 == "ENDTWITTER" | V3 == "ENDNEWS")[1,3]
    
    # Remove "END" from end-tokens
    writing_style <<- gsub("END", "", writing_style)
    
    # Send writing_style to index.html
    output$text2 <- renderText({writing_style})
    
    
    
    
  })
  
})
