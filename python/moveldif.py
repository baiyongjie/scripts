# -*- coding: utf-8 -*-
# create 20180408 / by: baiyongjie
import os,shutil,time

def moveFile(fileList):
    condition=False
    for fileName in fileList:
        if fileFormat in fileName:
            print("Start Moveing  {}".format(fileName))
            logFile=open("moveldap.log", 'a')
            logFile.write(time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(time.time())))
            logFile.write("  {} ->  {}{} \n".format(fileName, TARGET_URL, fileName))
            shutil.move(ORIGNAL_URL+fileName,TARGET_URL+fileName)
            condition=True


if __name__=="__main__":
    global ORIFINAL_URL,RARGET_URL
    ORIGNAL_URL="C:\\Users\\baiyongjie\Desktop\A-ldap\\"
    TARGET_URL="E:\A- Ldap\LdapManager\\"
    fileFormat=".ldif"
    moveFile(os.listdir(ORIGNAL_URL))