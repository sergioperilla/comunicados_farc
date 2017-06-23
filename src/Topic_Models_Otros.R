# Trabajo Final  Big Data for Public and Private Sectors
# Por: Sergio Perilla
# Tema: Análisis de texto sobre los comunicados de las FARC y 
#       opinión política en el tiempo.

# *********************
# TOPIC MODELING OTROS
# *********************
library("tm")
library("SnowballC")
library('stringi')
library('beepr')

setwd("C:/Users/sergi/Dropbox/Universidad/Semestre 11M/Big Data PP/Trabajo Final/Comunicados/Otros")

# Cargar mis docs
filenames <- list.files(getwd(), pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{1}") 
# Aplicar la función readLines a mis docs, para que sean un vector de chr 
files <- lapply(filenames, function(x) readLines(x, encoding="latin1"))

files <- lapply(files, function(x) stri_trans_general(x, "latin-ascii"))

# Hacer un Corpus con los vectores
docs <-Corpus(VectorSource(files))

writeLines(as.character(docs[3]))

# Arreglar el Corpus
docs <- tm_map(docs, content_transformer(tolower))
toSpace <- content_transformer(function(x, pattern) { return (gsub(pattern, " ", x))})
# Limpiar chr especiales y convertirla en espacio
docs <- tm_map(docs, toSpace, "-")
docs <- tm_map(docs, toSpace, "’")
docs <- tm_map(docs, toSpace, "‘")
docs <- tm_map(docs, toSpace, "•")
docs <- tm_map(docs, toSpace, "”")
docs <- tm_map(docs, toSpace, "“")
docs <- tm_map(docs, removePunctuation) # Remover Puntuaciónx
docs <- tm_map(docs, removeNumbers) # Remover Números
docs <- tm_map(docs, removeWords, stopwords("spanish")) # Remover Stopwords
docs <- tm_map(docs, stripWhitespace) # Remover Espacios en blanco


docs <- tm_map(docs,stemDocument) #Stemming en los docs

myStopwords <- c("página", "pagina", "final", "si", "sí",  "artículo", 
                 "título", "capìtulo", "capítulo", "titulo", "parágrafo", 
                 "dicho", "demá", 'dema',"así", "acción", "i", "ii", 
                 "iii", "iv", "v", "vi", "especi", "manera", "est", "sobr", 
                 "punto", "dond", "ant", "part", "tal", "ptn", "toda", "entr", 
                 "difer", "paí", "ser", "local", "forma", "cada", "protocolo", 
                 "cualquier", "component","integrant", "siguient", "debera", 
                 "sala", "necesario", "plane", "acceso", 'mas', 'colombiano', 
                 'dia', 'siempre', 'sino', 'tambien', 'punto', 'dos', 'asi', 
                 'toda', 'ano', 'sur','siempr', 'hoy', 'hace', 'siempr', 
                 'uso', 'millon', 'jefe', 'debe', 'grand', 'mismo', 'vez', 'pued',
                 'nunca', 'vida', 'momento', 'hora', 'hecho', 'senor', 'queremo',
                 'san', 'hacer')

docs <- tm_map(docs, removeWords, myStopwords) # Remover mis StopWords

dtm <- DocumentTermMatrix(docs) #Crear document-term matrix


library("topicmodels")
# Parametros
burnin <- 4000 
iter <- 2000
thin <- 500
seed <-list(2003,5,63,100001,765)
nstart <- 5
best <- TRUE

k <- 5 # Topics

# LDA por Gibbs Sample
ldaOut <-LDA(dtm,k, method="Gibbs", control=list(nstart=nstart, seed = seed, 
                                                 best=best, burnin = burnin, 
                                                 iter = iter, thin=thin))
beep(sound="mario")
# Los resultados
ldaOut.topics <- as.matrix(topics(ldaOut))
table(ldaOut.topics)

#top 6 terms in each topic
ldaOut.terms <- as.matrix(terms(ldaOut,10))


#probabilities associated with each topic assignment
topicProbabilities <- as.data.frame(ldaOut@gamma)

table(ldaOut.topics)
ldaOut.terms