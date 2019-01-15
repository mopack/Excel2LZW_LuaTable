# -*- coding: utf-8 -*-
import xlrd
import sys
import os
import re
import codecs

reload(sys)
sys.setdefaultencoding("utf-8")
myWorkbook = xlrd.open_workbook('global_msgs.xlsx') # load file

mySheets = myWorkbook.sheets()
mySheet = mySheets[0]
nrows = mySheet.nrows
ncols = mySheet.ncols

fo = open ("ToLuaTest.lua","w")
fo.write ("pTable={\n")
for i in range(6,nrows):
    fo.write ("\t{") 
    name_str = str(mySheet.cell(i,0).value).replace("\n","\\n") # replace \n to \\n
    msg_str = str(mySheet.cell(i,1).value).replace("\n","\\n") # replace \n to \\n
    fo.write ("name=\"" + name_str + "\",msg=\"" + msg_str + "\"},\n")
fo.write ("}")
fo.close