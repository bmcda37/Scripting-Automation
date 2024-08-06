#!

import configparser
import os
import shutil

#Create a folder for any new groups in host
def create_folder():
    config = configparser.ConfigParser()
      
    with open('host.ini', 'r') as f:
        config.read_file(f)
    
        for section in config.sections():
                
            src_dir = './general'
            dst_dir = f'./{section}'
                
            #If the group does not have a directory make the directory
            if not os.path.exists(dst_dir):
                try:
                    print(f'Creating folder: {dst_dir}')
                    os.makedirs(dst_dir)
                except OSError as o:
                    print(f'Error making directory for {section}: {o}')    
                
            #If the group does have a directory
            if os.path.exists(dst_dir):
                
                #Lists all the files in my general directory
                files = os.listdir(src_dir)

                #Get the full path with file name
                for file_name in files:
                    src_addr = os.path.join(src_dir, file_name)
                    dst_addr = os.path.join(dst_dir, file_name)

                #If there is no file in my src directory
                    if os.path.isfile(src_addr) and not os.path.isfile(dst_addr):
                        print(f'File exists in {src_addr}. Copying the files...')
                    
                        try:
                        # Copy the folder recursively to the new location
                            shutil.copy2(src_addr, dst_addr)
                            print(file_name)
                            # Replace values in the copied file
                            switch("<group>",section, dst_addr)   
                        except IOError as e:
                            print(f'Errory copying file {file_name} to {dst_addr}: {e}')
                    else:
                    #Search the files that exists and change any <group> to section name.
                        switch("<group>",section, dst_addr)

def switch(old, new, file_path):
    #file_path = "./general/test.txt"
    
    # Read the file's content
    with open(file_path, "r") as f:
        file_data = f.read()
    
    # Replace <group> with the source value
    file_data = file_data.replace(old, new)
    
    # Write the updated content back to the file
    with open(file_path, "w") as f:
        f.write(file_data)


if __name__ == "__main__":
    create_folder()