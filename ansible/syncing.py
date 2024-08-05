import configparser
import os
import glob
import subprocess
import time
import shutil


# Read the config file
config = configparser.ConfigParser()
config.sections()

#Create a folder for any new groups in host
def create_folder():
       
    for section in config.sections():
            src_dir = './'
            dst_dir = f'./{section}'

            if not os.path.exists(dst_dir):
                print(f'Creating folder: {dst_dir}')
                os.makedirs(dst_dir)

            files = os.listdir(src_dir)

            for file_name in files:
                src_addr = os.path.join(src_dir, file_name)
                dst_addr = os.path.join(dst_dir, file_name)

                if os.path.isfile(src_addr):
                    # Copy the folder recursively to the new location
                    shutil.copytree(src_addr, dst_addr)
                    # Replace values in the copied file
                    for file in dst_addr:
                        with open(file, 'r') as f:
                            filedata = f.read()
                            subprocess.run(["sed", "-i", f"s/<group>/{section}/g", file])
                else:
                    print(f'{src_addr} is not a file.')
  
  

#def sync_files(src,dst):
#    command = ["rsync", "-av", src, dst]
#    subprocess.run([command], capture_output=True)


if __name__ == "__main__":
    create_folder()
    #src = "./"
    #dst = "../"