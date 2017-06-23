# Trabajo Final  Big Data for Public and Private Sectors
# Por: Sergio Perilla
# Tema: Análisis de texto sobre los comunicados de las FARC y 
#       opinión política en el tiempo.

# **********************************
# CLASIFICAR LOS ARCHIVOS POR AUTOR
# **********************************

require('stringr')
require('base')

main_path <- 'C:/Users/sergi/Dropbox/Universidad/Semestre 11M/Big Data PP/Trabajo Final/'
path_data <- paste0(main_path, 'Datasets/')
path_comunicados <- paste0(main_path, 'Comunicados/')
path_code <- paste0(main_path, 'Code/')
comunicados <- read.csv(file = paste0(path_data,'Comunicados_FARC.csv'), sep = ';', stringsAsFactors = F )

comunicados$Autor <- str_trim(comunicados$Autor)
comunicados$Autor <- tolower(comunicados$Autor)
comunicados$Autor_G <- gsub("([A-Za-z]+).*", "\\1", comunicados$Autor)

for (i in 1:length(comunicados$Autor_G)) {
  if (comunicados$Autor_G[i] == 'secretariado') {
    comunicados$Autor_G[i]='secretariado'
  }
  else if (comunicados$Autor_G[i] != 'secretariado') {
    comunicados$Autor_G[i]='otros'
  }
}

comunicados$name <- paste0(comunicados$Fecha, '_',as.character(comunicados$ID), '.txt')

path_comunicados_secretariado <- paste0(path_comunicados, 'Secretariado/')
path_comunicados_otros <- paste0(path_comunicados, 'Otros/')

Old_list_files <- rev(paste0(path_comunicados,list.files(path_comunicados)))

# Este loop organiza en carpetas por autor
for (i in 1:length(comunicados$X)) {
  if (comunicados$Autor_G[i] == 'secretariado') {
    comunicados$Old_files[i] <- paste0(path_comunicados_secretariado, comunicados$name[i])
  }
  else if (comunicados$Autor_G[i] == 'otros') {
    comunicados$Old_files[i] <- paste0(path_comunicados_otros, comunicados$name[i])
  }
  file.copy(Old_list_files[i], comunicados$Old_files[i])
}

# Guardar los csv's
write.csv(comunicados, paste0(path_data,'Comunicados_FARC_Agg.csv'))

comunicados_otros <- subset(comunicados, Autor_G=='otros')
write.csv(comunicados_otros, paste0(path_data,'Comunicados_FARC_Otros.csv'))

comunicados_secretariado <- subset(comunicados, Autor_G=='secretariado')
write.csv(comunicados_secretariado, paste0(path_data,'Comunicados_FARC_Secretariado.csv'))