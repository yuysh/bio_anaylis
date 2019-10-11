path = 'C:/Users/FREEDOM/Desktop/TCGA_data/after_note2.csv'
path1 ='C:/Users/FREEDOM/Desktop/TCGA_data/group_text.csv'
express_rec <- read.csv(path,headers <- T)#��ȡ�������;
group_text <- read.csv(path1,headers <- T)#��ȡ�������
library(edgeR)#����edgeR��

express_rec <- express_rec[,-1]
rownames(express_rec) <- express_rec[,1]
express_rec <- express_rec[(-1)]#�����������
rownames(group_text) <- group_text[,1]
group_text <- group_text[c(-1)]#���ط������

group <-factor(group_text$group)

dge <- DGEList(counts = express_rec,group = group)#����DEList����
y <- calcNormFactors(dge)#����calcNormFactor������DEList������б�׼��(TMM�㷨) 

#������ƾ��󣬸�Limma�����ƣ�
rownames(group_text) <- group_text[,1]
group_text <- group_text[c(-1)]
Group <- factor(group_text$group,levels = c('Tumor','Normal'))
design <- model.matrix(~0+Group)
colnames(design) <- c('Tumor','Normal')
rownames(design) <- rownames(group_text)#�����������

y <- estimateDisp(y,design)#������ɢֵ��Dispersion��
plotBCV(y)
fit <- glmQLFit(y, design, robust=TRUE)#��һ��ͨ��quasi-likelihood (QL)���NBģ��
head(fit$coefficients)

TU.vs.NO <- makeContrasts(Tumor-Normal, levels=design)#��һ����Ҫ�����ȽϾ���
res <- glmQLFTest(fit, contrast=TU.vs.NO)#��QL F-test���м���
# ig.edger <- res$table[p.adjust(res$table$PValue, method = "BH") < 0.01, ]#���á�BH��������
result_diff <- res$table#ȡ�����յĲ������
write.csv(edge_diff,'C:/Users/FREEDOM/Desktop/TCGA_data/edgeR_diff2.csv')
edge_diff <- subset(result_diff,abs(result_diff$logFC)>1.5&result_diff$PValue<0.05)


#���ƻ�ɽͼ;
library(ggplot2)#���ػ�ɽͼ����
library(ggrepel)

gene_name <- data.frame(rownames(result_diff))
rank_data <- cbind(gene_name,result_diff)
colnames(rank_data)[1] <- c('gene_name')

rank_data <- rank_data[order(rank_data[,5]),]#��������pvalue��С��������
rownames(rank_data) <-rank_data[,1]
rank_data <- rank_data[c(-1)]
rank_data$names <- rownames(rank_data)
volcano_names <- rownames(rank_data)[1:5]#ȡpvalue��С���������

rank_data$ID2 <- ifelse((rank_data$names %in% volcano_names)&abs(rank_data$logFC)>3
                        ,as.character(rank_data$names),NA)#�ھ���res_data�����д���һ���ĵ��У���������|log2folchange|����3 �Ļ����������򱣴�ΪNA��
png(file="C:/Users/FREEDOM/Desktop/TCGA_data/edege_voloun_log2.png", bg="transparent")#�ȴ���һ��ͼƬ
boundary = ceiling(max(abs(rank_data$logFC)))#ȷ��x��ı߽磻
threshold <- ifelse(rank_data$PValue<0.05,ifelse(rank_data$logFC >=3,'UP',ifelse(rank_data$logFC<=(-3),'DW','NoDIFF')),'NoDIFF')#���÷ֽ緧ֵ
ggplot(rank_data,aes(x=rank_data$logFC,y =rank_data$PValue,color=threshold))+geom_point(size=1, alpha=0.5) + theme_classic() +
  xlab('log2 fold_change')+ylab(' log2 p-value') +xlim(-1 * boundary, boundary) + theme(legend.position="top", legend.title=element_blank()) + geom_text_repel(aes(label=rank_data$ID2))#��ɽͼ���ı���ǩ��ע��
dev.off()#�����ɽͼͼƬ��






