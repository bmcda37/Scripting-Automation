from subprocess import *
import time
     
'''NOTES FOR CODE
shell=True --allows you to pass in additional arguements within your commands.
check=True -- returns a non-zero error code exit status. If this is not true, the exception will be thrown.
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
    try:
        run(["useradd", "-m", "-s", "/bin/bash", username], check=True)
        run(["chpasswd"], input=f"{username}:{password}", check=True, shell=True)
        run(["usermod", "-aG", "sftp", username], check=True)
        
        #Disabling ssh for the users
        
        run(["sudo", "usermod", "--shell", "/sbin/nologin", username], check=True)
        
        #Set drectory permissions for the user
        
        run(["sudo", "mkdir", "-p", f"/sftp/chroot/{username}/data"], check=True)
        run(["sudo", "chown", "root:sftp", f"/sftp/chroot/{username}"], check=True)
        run(["sudo", "chown" f"{username}:sftp /sftp/chroot/{username}/data"], check=True)
        run(["sudo", "chmod 750", f"/sftp/chroot/{username}"], check=True)
        run(["sudo", "chmod", "770", f"/sftp/chroot/{username}/data"], check=True)
        
        run(["sudo", "mkdir", "-p", f"/sftp/sftpHold/{username}/data"], check=True)
        run(["sudo", "chown", "root:sftp", f"/sftp/sftpHold/{username}/data"], check=True)
        run(["sudo", "chmod", "750", f"/sftp/sftpHold/{username}"], check=True)
        run(["sudo", "chmod", "770", f"/sftp/sftpHold/{username}/data"], check=True)
        
        print(f"User {username} has been created and added to the 'sftp' group with directory permissions set.")
        return True
    
    except CalledProcessError as e:
        print(f"Error wile creating user: {e}")
        return False
        
# Running the program
program()