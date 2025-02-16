getAdditionalEndMessage <- function(id, type="database", parameters, txt){
  additional_message <- tryCatch( 
  
    expr= {
      if (type=="database") {
      table = parameters[parameters$parameter=="additionalEndMessageTable", "value"]
      val_col = parameters[parameters$parameter=="additionalEndMessageValueColumn", "value"]
      id_col = parameters[parameters$parameter=="additionalEndMessageIdColumn", "value"]
      db_name = Sys.getenv("DB_NAME")
      
      transaction1 = paste0("select @value:= ", val_col, " from `", db_name, "`.`", table,
                            "` where ", id_col, " is null limit 1 for update")
      transaction2 = paste0("update `", db_name, "`.`", table, "` set id='",
                            id, "' where ", val_col, "=@value and ", id_col, " is null")
      query = paste0("select ", val_col, " from `", db_name, "`.`", table, "` where ", 
                     id_col, "='", id, "'")
      transaction = c(transaction1, transaction2)
      
      result = sendDatabase(username=Sys.getenv("DB_USERNAME"),
                            password=Sys.getenv("DB_PASSWORD"),
                            dbname=Sys.getenv("DB_NAME"),
                            host=Sys.getenv("DB_HOST"),
                            port=Sys.getenv("DB_PORT"),
                            id=id,
                            tableName=table,
                            tableQuery=query)
      
      if (length(result$voucher)==0) {
        result = sendDatabase(username=Sys.getenv("DB_USERNAME"),
                              password=Sys.getenv("DB_PASSWORD"),
                              dbname=Sys.getenv("DB_NAME"),
                              host=Sys.getenv("DB_HOST"),
                              port=Sys.getenv("DB_PORT"),
                              id=id,
                              tableName=table,
                              transaction=transaction,
                              tableQuery=query)
      }
      
      if (length(result$voucher)==0) {
        message = txt[txt$text_type=='additionalEndMessageFromDatabaseNoText', "text"]
      } else 
      {
        message = paste(txt[txt$text_type=='additionalEndMessageFromDatabaseText', "text"], 
                        "<center><strong>", paste(result$voucher, collapse = ', '), "</strong></center>")
      }
      
      print(message)
      return(message)
      }
    },
    
    error = function(e) {
        logerror(paste0(id, " Failed to get additional message! ", e))
        message = txt[txt$text_type=='additionalEndMessageFromDatabaseNoText', "text"]
        print(message)
        return(message)
    }
  )
  
}



