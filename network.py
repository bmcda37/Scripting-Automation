#! /usr/bin/env/python3

#Redwriting the moving_users script but in python for practice

from subprocess import *


def create_user_and_permissions(usr, pwd) :
    run(['useradd', usr])
    
    
    
    