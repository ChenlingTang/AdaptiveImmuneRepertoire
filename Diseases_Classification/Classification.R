#### xgboost/nnet to analyse allocated data ######

library(readr)
library(ggplot2) 
library(pheatmap)
library(nnet)
library(lattice)
library(caret)
library(xgboost)

### read file --------------------------------------------
Args <- commandArgs(T)

data <- read.csv(Args[1],header = TRUE,sep = "\t")
name <- Args[2]

## health
health <- data[data$Name == "Health",]

testset_index_health <- sample(1:nrow(health), trunc(nrow(health)/4))

testset_health <- health[testset_index_health, ]

trainset_health <- health[-testset_index_health, ]


## Positive
positive <- data[data$Name == "Dermatophagoides_positive",]

testset_index_positive <- sample(1:nrow(positive), trunc(nrow(positive)/4))

testset_positive <- positive[testset_index_positive,]

trainset_positive <- positive[-testset_index_positive,]

## Negative
negative <- data[data$Name == "Dermatophagoides_negative",]

testset_index_negative <- sample(1:nrow(negative), trunc(nrow(negative)/4))

testset_negative <- negative[testset_index_negative,]

trainset_negative <- negative[-testset_index_negative,]


testset <- as.data.frame(rbind(testset_health, testset_positive, testset_negative))
trainset <- as.data.frame(rbind(trainset_health, trainset_positive, trainset_negative))

### xgboost --------------------------------------------

col <- ncol(trainset)
trainset$id <- as.numeric(as.factor(trainset$Name))
train_mat <- trainset[,2:col]

testset$id <- as.numeric(as.factor(testset$Name))
test_mat <- testset[,2:col]

train_label<-as.matrix(as.numeric(as.factor(trainset$id))-1)
test_label<-as.matrix(as.numeric(as.factor(testset$id))-1)

dtrain<-xgb.DMatrix(data= as.matrix(train_mat),label=train_label)
dtest<-xgb.DMatrix(data=as.matrix(test_mat))

## train the model
param <- list(objective= "multi:softprob",
              eval_metric= "merror",
              eval_metric= "mlogloss",
              num_class = 3,
              nthread= 8,
              subsample = 0.8,
              colsample_bytree= 0.9,
              max_depth = 8,
              eta = 0.1
)

bst = xgb.train(param=param,data = dtrain, nrounds=3000)

pred = predict(bst,dtest)
pred = matrix(pred,ncol=3,byrow=T)
pred=format(pred,digits=3,scientific=FALSE)
pred_label<-max.col(pred)-1

tab<-table(pred_label,test_label)
colnames(tab) <- rev(unique(as.factor(testset$Name)))
rownames(tab) <- rev(unique(as.factor(trainset$Name)))
tab_n <- apply(tab,MARGIN = 2, function(X) X/sum(X)*100)

F_xg <- pheatmap(tab_n, color = colorRampPalette(c('white','orange','red'), bias =1)(30), cluster_row = FALSE, cluster_cols = FALSE, main = paste(name,"xgboost",sep = "_"))
ggsave(paste(name,"xgbost_heatmap.pdf",sep = "_"), plot = F_xg)

result <- confusionMatrix(tab)
R_xg <- result$overall
write.table(R_xg, file= paste(name,"xgbost_result.txt",sep = "_"),quote=F,col.name=TRUE,row.names=TRUE)


### nnet --------------------------------------------
data.nn = nnet(as.factor(Name) ~ .,data = trainset,size = 1,decay = 5e-4,rang = 1/max(trainset[,-1]),maxit = 5000)

nnetdata.predict = predict(data.nn,testset,type = "class")

nn.table = table(nnetdata.predict,testset$Name)

nn.table_n <- apply(nn.table,MARGIN = 2, function(X) X/sum(X)*100)

result0 <- confusionMatrix(nn.table)

R_nn <- result0$overall
write.table(R_nn, file= paste(name,"nnet_result.txt",sep = "_"),quote=F,col.name=TRUE,row.names=TRUE)

F_nn <- pheatmap(nn.table_n, color = colorRampPalette(c('white','orange','red'), bias =1)(30), cluster_row = FALSE, cluster_cols = FALSE, main = paste(name,"nnet",sep = "_"))
ggsave(paste(name,"nnet_heatmap.pdf",sep = "_"), plot = F_nn)
