###########################################
######### Symplicity CSM REST API #########
###########################################

import sys
if sys.version_info[0] < 3:
    from StringIO import StringIO
else:
    from io import StringIO
import requests
import setup
import pandas as pd
import time as time
import re
import os

PAYLOAD = {'category':'student', 'dateRange':'["2017-05-22","2018-05-21"]', 'page':'1', 'perPage':'5', 'customFields':'1'}

r = requests.get('https://byu-csm.symplicity.com/api/public/v1/calendar-events', params = PAYLOAD, headers=setup.HEADERS)
print(r.json())


PAYLOAD = {'field':'majors'}
field = PAYLOAD['field']
r = requests.get('https://byu-csm.symplicity.com/api/public/v1/picklists/students/%s' %field , headers=HEADERS)
print(r.json)
for major in r.json():
    print(major['value'])
