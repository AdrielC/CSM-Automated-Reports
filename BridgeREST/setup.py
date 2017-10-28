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
USERNAME = "bccbrand"
TOKEN = "phFJOCLh7+6tXa/CuP4uTbgZDwlBjQyORbc/sI1C6/yLylYouRzjLPkM/EMiKennN0tlp0TkZGMnQTLq1QOb+XRu7aOzUa5ML/kkM8Ne9y3IS+aeYsbhW20WUdv0ifJgdnsxI3D6iJY="
HEADERS = {"Authorization":"Token %s" % TOKEN}
dPAYLOAD = {'format':'csv'}

### If your report is 20,000 rows or more, you can store the JSON
###### type data from the pulled reports temporarily your disk in MongoDB.
MONGO_ADDRESS = "127.0.0.1"
MONGO_PORT = 27017
