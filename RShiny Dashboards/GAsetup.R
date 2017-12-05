token <- Auth("294470013201-qrdobt7mfpffbvpcfsfsap74grr94566.apps.googleusercontent.com", "osOqE2SI8bj8obDz8GkP_B_9") # first Client ID, then Client Secret

save(token,file="./token_file") # This will save the token on your computer so you do not need to authenticate everytime

ValidateToken(token)

