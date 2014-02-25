#' Get Login credentials for NBN access
#' 
#' Opens a dialog box for the user to enter credentials if
#' username and password are not given, also manages cookies.
#' 
#' @export
#' @param username optional character giving username
#' @param password optional character giving password
#' @details This function is used within the getOccurrences function and should not
#' normally need to be used by users. It automatically handles cookies and only
#' prompts users for username and password if no cookies exist. The facility to provide
#' a username and password has been added for people who may have issues with cookies
#' or perhaps share an account with a number of others, however hardcoding usernames and
#' passwords has obvious security issues.
#' @return NULL
#' @author Tom August, CEH \email{tom.august@@ceh.ac.uk}


nbnLogin <- function(username = NULL, password = NULL){
    
    # set up Curl
    agent = "rnbn v0.1"
    options(RCurlOptions = list(sslversion=3L, ssl.verifypeer = FALSE))
    curl = getCurlHandle()
    cookies <- 'rnbn_cookies.txt'
    curlSetOpt(cookiefile = cookies, cookiejar = cookies,
               useragent = agent, followlocation = TRUE, curl=curl)
    
    # If we are not providing a username and password see if we have cookies
    if(is.null(username) | is.null(password)){    
        # See if we are known
        whoamI <- "https://data.nbn.org.uk/api/user"
        
        # sometimes the server fails to handshake, i try to get around this by trying again
        a=0
        while(a<5){
            resp_who <- try(getURL(whoamI, curl = curl), silent=TRUE)
            if(is.null(attr(resp_who,'class'))) attr(resp_who,'class') <- 'success'
            if(grepl('Error report', resp_who)) stop('NBN server return included "Error report" when checking if you are logged in. This can happen when the NBN servers are down, check https://data.nbn.org.uk/ to see if there is a known issue')
            if(attr(resp_who,'class') == 'try-error'){
                a=a+1
                if(a==5) stop(paste('When trying to check your login status the NBN did not produce the expected response, here is the error I am getting:', resp_who))
            } else {
                a=999
            }
        }
        
        attr(resp_who,'class') <- NULL
        resp <- fromJSON(resp_who, asText = TRUE) # resp$id == 1 if we are not logged in
        #print(resp)
    
        #Login in with dialog box
        if(resp['id'] == 1){
            
            # Create the directory for cookies
            #dir.create(cookiePath, showWarnings = FALSE)
            
            # Get username and password
            UP <- getLogin()
            dusername <- UP$username
            dpassword <- UP$password
            
            # Create login URL
            urlLogin <- paste("https://data.nbn.org.uk/api/user/login?username=",dusername,
                              "&password=", dpassword, sep='')
            
            # Check that login was a success (if not stop)
            resp <- fromJSON(getURL(urlLogin,curl=curl), asText=TRUE) #login result
            if(!resp$success){
                stop('Username and password invalid, have another go')
            } else {
                print('Login successful')
            }
        }
    } else { # If we have specified a username and password
        
        # Create login URL
        urlLogin <- paste("https://data.nbn.org.uk/api/user/login?username=",username,
                          "&password=", password, sep='')
        
        # Check that login was a success (if not stop)
        resp <- fromJSON(getURL(urlLogin,curl=curl), asText=TRUE) #login result
        if(!resp$success){
            stop('Username and password invalid, have another go')
        } else {
            print('Login successful')
        }
        
    }   
        
    # To write cookies to file we need to remove the curl object and run garbage collection
    rm(curl)
    invisible(gc())
}
