from subprocess import *
import time
     
'''PRACTICE CODE

    for i in range(0,20):
        if(i == 2):
            print("value = " + str(i))
            continue;
        print(i)
        
    print("\nNumber ends at " + str(i))

    print("\nProgram Ends!");


    with open('test.txt', 'w') as f:
    p1=run("ls -l", stdout=f, text=True)

'''
    

def program(): 
    while True:
        print("Enter the username or 'q' to quit: ")
        username = input()
        if username != "q":
            print(f"Enter your password for {username}")
            password = input()      

            if username and password is not None:
                time.sleep(2)
                creating_users_permissions(username, password)
                time.sleep(2)
                print(f"New user: {username} with password {password} was created successfully.")
                time.sleep(2)

        if username == "q":
            print("Exiting Program!")
            break

def creating_users_permissions(username, password):
    
    print(f"Creating permissions for {username}")
    
    run(f"useradd -m -s /bin/bash {username}")
    run(f"{username}:{password} | chpasswd")
    run(f"usermod -aG sftp {username}")
    
    run(f"sudo usermod --shell /sbin/nologin {username}")
    #Set drectory permissions for the user
    run(f"sudo mkdir -p /sftp/chroot/{username}/data")
    run(f"sudo chown root:sftp /sftp/chroot/{username}")
    run(f"sudo chown {username}:sftp /sftp/chroot/{username}/data")
    run(f"sudo chmod 750 /sftp/chroot/{username}")
    run(f"sudo chmod 770 /sftp/chroot/{username}/data")
    
    run(f"sudo mkdir -p /sftp/sftpHold/{username}/data")
    run(f"sudo chown root:sftp /sftp/sftpHold/{username}/data")
    run(f"sudo chmod 750 /sftp/sftpHold/{username}")
    run(f"sudo chmod 770 /sftp/sftpHold/{username}/data")
    
    print(f"User {username} has been created and added to the 'sftp' group with directory permissions set.")

# Running the program

program()