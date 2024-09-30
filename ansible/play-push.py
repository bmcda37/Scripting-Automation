#!/usr/bin/env python3

'''
WARNING:
This script will ask you for input on the okay you want to push
to groups and add that play to the groups directory.
Will automaticaly update the 'hosts:' portion of play.
Group has to be existing.
Will keep pushing script unti you type 'q' or 'quit'

'''
import configparser
import os
import shutil

def transfer():
    #Take input for playbook needing to be pushed
    file = input("Enter fullname of play with file extension from playbook dir you want to be pushed out?\n")
    src = './general'
    
    config = configparser.ConfigParser()
    with open('./host.ini', 'r') as f:
        config.read_file(f)  
    
    while input != 'q' or 'quit':
        #Take input from the playbook needing pushed and compare to files in playbook dir
        
        try:
            if file in os.listdir({src}):
                #Take input for dst directory to copy file too. Look at input and compare to section in hosts.ini
                group = input(f'File {file} found. What group would you like to copy this file to?')
                #return group
                print(f'Copying {file} to {group} directory')
            #if group in config.sections():
            #    shutil.copy2(file,group) 

            
            
            #Change the <group> variable to group stated in input
            #TODO Use python replace method?
        
        except OSError as e:
            print(f'File not found error: {e}')
            print('Enter the file along with the file name.')

if __name__ == "__main__":
    transfer()