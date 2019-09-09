suppressMessages(library(parallel))
suppressMessages(library(BiocGenerics))
suppressMessages(library(Biostrings))

Args <- commandArgs(T)

subtype <- read.csv(file= Args[1], sep = "\t", header = FALSE)

consensus <- consensusString(DNAStringSet(subtype[,1]), ambiguityMap = "N", threshold = 0.50001)

tag <- Args[2]

write.table(consensus, file = paste(tag,"consensus.txt", sep = "_"), quote = FALSE, sep = "\t", col.names = FALSE, row.names = FALSE)

