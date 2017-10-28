###############################################
########## Symplicity CSM REST API ############
###############################################
##                           M               ##
##                          MMM              ##
##                        MMMMMMM            ##
##                      IMMMMMMMMM           ##
##                     MMMM MMM MMMM         ##
##                   MMMMM  MMM  MMMM:       ##
##                  MMMM:   MMM   IMMMM      ##
##                MMMMM     MMM     MMMMM    ##
##              MMMMMMMMMMMMMMM      MMMMM   ##
##             MMMMMMMMMMMMMMMM       MMMMM  ##
##           MMMMM          MMM      MMMM    ##
##          MMMMM           MMM    MMMMM     ##
##        MMMMM             MMM  IMMMM       ##
##      MMMMM               MMM MMMMN        ##
##     MMMMM                MMMMMMMM         ##
##   MMMMM                  MMMMMM           ##
##  MMNM                    MMMM             ##
###############################################
######### Symplicity CSM REST API #############
###############################################
# https://github.com/AdrielC/

### This setup document is where you input everything you need to
###### authenticate and authorize your queries to simplicity CSM.

### Simply replace the "example" text with your own credentials.
### The CSM REST API Token can be acquired from submitting a support ticket Symplicity (details on
###### how to obtain the token are outlined in the "NewToken.txt" file.

### Input your CSM REST API username and token
# USERNAME = "example" Change this to your username. You don't really need this, but it's better to have just in case
# TOKEN = "token"
HEADERS = {"Authorization":"Token %s" % TOKEN}

### If your report is 20,000 rows or more, you can store the JSON
###### type data from the pulled reports temporarily your disk in MongoDB.
MONGO_ADDRESS = "127.0.0.1" # This points to your local drive
MONGO_PORT = 27017 # You can use this, or choose your own port to access the database
