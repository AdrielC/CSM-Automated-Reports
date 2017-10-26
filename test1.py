import subprocess

print("I am now going to try and run some ☈ CODE⁉️⁉️⁉️⁉️")
## Integrate R script to further clean the reports
command = 'Rscript'
path2script = '~/MAIN/BCC/Club data/ClubReportMaster1.R'
cmd = [command, path2script]
x = subprocess.check_output(cmd, universal_newlines=True)
