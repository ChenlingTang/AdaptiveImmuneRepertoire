######### calculate the levensthin distance for each person (XX_CDR3_AA)  #########
#### the second Args is the select clone number (from high rate to low rate)  #####

library(reshape)
library(stringdist)

Args <- commandArgs(T)

file<- read.csv(Args[1],header = FALSE,sep = "\t")
sc<- read.csv(Args[2],header = FALSE,sep = "\t")

file_l <- file[1:Args[3],1]

sc_l <- sc[,1]

#str(file_l)
leven <- stringdistmatrix(file_l,sc_l, method = 'lv', useNames = TRUE)
leven_m <- melt(leven)

leven_f <- leven_m[leven_m$value <= as.numeric(Args[4]), ]

#print(dim(leven_f))

leven_ff <- leven_f[,1]

write.table(leven_ff, file=paste("leven_dis", Args[4], Args[5], "txt",sep="_"),quote=F,col.name=F,row.names=F)
