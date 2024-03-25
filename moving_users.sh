#Create user and set permissions
create_user_and_permissions() {
    local username="$1"
    local password="$2"

    # Create user with username input
    sudo useradd -m -s /bin/bash "$username"

    # Set password for user
    echo "$username:$password" | chpasswd

    # Add users to the "sftp_users" group
    sudo usermod -aG sftpusers "$username"

    #Prevent SSH
    sudo usermod --shell /sbin/nologin "$username"

    # Set directory permissions for the user
    sudo mkdir -p /sftpusers/chroot/"$username"/data
    sudo chown root:sftpusers /sftpusers/chroot/"$username"
    sudo chown "$username":sftpusers /sftpusers/chroot/"$username"/data
    sudo chmod 750 /sftpusers/chroot/"$username"
    sudo chmod 770 /sftpusers/chroot/"$username"/data

    sudo mkdir -p /sftpusers/sftpHold/"$username"/data
    sudo chown root:sftpusers /sftpusers/sftpHold/"$username"/data
    sudo chmod 750 /sftpusers/sftpHold/"$username"
    sudo chmod 770 /sftpusers/sftpHold/"$username"/data

    # Confirmation
    echo "User '$username' has been created and added to the 'sftp_users' group with directory permissions set."
}

# Add multiple users
while true; do
    read -p "Enter username (or 'q' to quit): " username
    if [ "$username" = "q" ]; then
        break
    fi

    read -s -p "Enter password: " password
    echo #newLine

    create_user_and_permissions "$username" "$password"

done

