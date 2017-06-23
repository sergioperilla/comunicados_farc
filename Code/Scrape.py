# Trabajo Final  Big Data for Public and Private Sectors
# Por: Sergio Perilla
# Tema: Análisis de texto sobre los comunicados de las FARC y 
#       opinión política en el tiempo.

# *****************************
# SACRAPING PÁGINA DE LAS FARC
# *****************************

# ***************
# *** Parte 1 ***
# ***************

# Objetivo: Armar un Data Frame con todos los discursos de las FARC

# Importar paquetes para hacer scrapping
import requests
import re
import os
import time
import urllib.request
import socket
from bs4 import BeautifulSoup
import numpy as np
import pandas as pd

# Preliminar
    # Qué URL ?
    # Convierta el html en un text
    # Haga que se vea bonito a través de un soup

url='http://www.farc-ep.co/datos.html'
html = requests.get(url).text
soup=BeautifulSoup(html,"lxml")

# Iniciar Scrapping
    # Crear listas con cada una de las variabless
all_data=soup.find_all('li')
list_dates=re.findall('<span class="date pos_1">(.*?)<\/span>', str(all_data))
list_names=re.findall('.html">(.*?)<\/a>', str(all_data))
list_author=re.findall('',str(all_data))

list_linkF=[]
list_links=re.findall('<a href="(.*?)">', str(all_data))
prelinks=['http://www.farc-ep.co']*422

for i in range(0,len(list_links)):
    list_linkF.append(prelinks[i] + list_links[i])

# Hacer una lista compirmida con los datos
zipped=list(zip(list_dates,list_names,list_linkF))

# Convertir el zip en un dataframe de pandas
df=pd.DataFrame.from_records(zipped,columns=["Fecha", "Titulo Comunicado", "Link"])
df["ID"]=np.arange(422, 0, -1)

# ***************
# *** Parte 1.5 *
# ***************

# Objetivo: Encontrar el autor de cada uno de los discursos

# Crear una lista que contenga el autor del comunicado
# Loop haciendo scraping en cada una de las páginas con el comunicado
list_authorZ=[]
for i in range(1,423):
    try:
        dataZ=urllib.request.urlopen(df.Link[i], None ,timeout=10)
        print("Agarro link"+str(i))
        #time.sleep(5)
    except Exception:
        print("Oops, timed out?")
    except socket.timeout:
        print("Timed out!")
    soupZ=BeautifulSoup(dataZ, "lxml")
    
    # Request the Data in the tags p
    authorZ=soupZ.find_all('span', class_='itemAuthor')
    list_authorZ.append(re.findall('\t(.*?)<', str(authorZ)))
    if list_authorZ[i-1]=='\t\t\t\t\t' or list_authorZ[i-1]==['\t\t\t\t\t'] or list_authorZ[i-1]==[]:
        list_authorZ[i-1]=re.findall('>(.*?)<', str(authorZ))
        print("Encontre uno y lo meti, creo")

# Hacer cambio de listas vacias para evitar perder datos cuando se haga el strip
for i in range(len(list_authorZ)):
    if list_authorZ[i]==[]:
        list_authorZ[i]=['Error']
    else:
        list_authorZ[i]=list_authorZ[i]

# Pasar lista de listas a -> listas de strings
list_authorZ=[item for sublist in list_authorZ for item in sublist] 

# Strip cada una de las listas -> lista de listas
for i in range(len(list_authorZ)):
    list_authorZ[i]=list_authorZ[i].strip()

# Agresar la lista de autores al Data Frame
df["Autor"]=list_authorZ

# Guardar la base como un .csv
os.chdir('C:\\Users\\sergi\\Dropbox\\Universidad\\Semestre 11M\\Big Data PP\\Trabajo Final\\Datasets\\')
df.to_csv("Comunicados_FARC.csv",sep=";")

# ***************
# *** Parte 2 ***
# ***************

# Objetivo: Descargar los discursos en archivos de texto

os.chdir('C:\\Users\\sergi\\Dropbox\\Universidad\\Semestre 11M\\Big Data PP\\Trabajo Final\\Comunicados\\')
list_errores=[]
# Loop Scrape -> string -> txt
for i in range(0,422):
    try:
        data=urllib.request.urlopen(df.Link[i], None ,timeout=120)
        time.sleep(5)
        print("Agarro link"+str(i))
    except Exception:
        print("Oops, timed out?")
        list_errores.append(df.Link[i])
        continue
    
    soup2=BeautifulSoup(data, "lxml")
    
    # Request the Data in the tags p
    all_data2=soup2.find_all('p')
    
    # List to strings
    endstring=""
    for j in range(len(all_data2)):
        all_data2=soup2.find_all('p')[j].get_text()
        endstring=endstring+all_data2
        endstring=re.sub('[^A-Za-z0-9áéíóúÁÉÍÓÚñÑ]+', ' ', endstring)
        print("End String"+str(i))
    #Final clean of the string
    sep = 'URL'
    endstring = endstring.split(sep, 1)[0]
    
    # Strings to txt files
    f = open( df.Fecha[i] + '_' + str(df.ID[i]) +'.txt', 'w' )
    f.write(repr(endstring) + '\n' )
    f.close()
    print("Guardo"+str(i))

# Objetivo: Descargar los discursos en archivos de texto que no se descargaron
    # Los de list errores 

list_error_Fecha=[]
list_error_ID=[]

for n in range(len(df["ID"])):
    for k in range(len(list_errores)):
        if df["Link"][n]==list_errores[k]:
            list_error_Fecha.append(df["Fecha"][n])
            list_error_ID.append(str(df["ID"][n]))

# Loop Scrape -> string -> txt
list_errores2=[]
for i in range(len(list_errores)):
    try:
        data=urllib.request.urlopen(list_errores[i], None ,timeout=120)
        time.sleep(10)
        print("Agarro link" + str(i))
    except Exception:
        print("Oops, timed out?")
        list_errores2.append(list_errores[i])
        continue
    
    soup2=BeautifulSoup(data, "lxml")
    
    # Request the Data in the tags p
    all_data2=soup2.find_all('p')
    
    # List to strings
    endstring=""
    for j in range(len(all_data2)):
        all_data2=soup2.find_all('p')[j].get_text()
        endstring=endstring+all_data2
        endstring=re.sub('[^A-Za-z0-9áéíóúÁÉÍÓÚñÑ]+', ' ', endstring)
        print("End String"+ str(i))
    #Final clean of the string
    sep = 'URL'
    endstring = endstring.split(sep, 1)[0]

    # Strings to txt files
    f = open(list_error_Fecha[i] + '_' + list_error_ID[i] +'.txt', 'w' )
    f.write(repr(endstring) + '\n' )
    f.close()
    print("Guardo"+ str(i))