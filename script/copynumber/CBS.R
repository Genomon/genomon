#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

library(DNAcopy);

samplePath <- commandArgs()[5];

tempPaths <- strsplit(samplePath, "/")[[1]];
sampleName <- tempPaths[length(tempPaths)];

sample <- read.table(paste(samplePath, ".shmmg", sep=""), sep="\t");

tchr <- rep(0, length(sample[,1]));
for (i in 1:22) {
	tchr[sample[,1] == paste("chr", i, sep="")] <- i;
}
tchr[sample[,1] == "chrX"] <- 23;
tchr[sample[,1] == "chrY"] <- 24;


####
pind <- (sample[,6] > 30 & sample[,7] > 30) | (rowSums(sample[, 8:11]) > 80);

chr <- tchr[pind];

pos <- sample[pind,2];

len <- sample[pind, 4];
GCrate <- sample[pind,5] / sample[pind, 4];
sdepth <- sample[pind, 6] + sample[pind, 7];
loc_ind <- sample[pind, 12];

tsignal <- (sample[,7] + 1) / (sample[,6] + 1);
signal <- tsignal[pind];


X <- cbind(1, GCrate);
beta <- as.vector(solve(t(X) %*% X) %*% t(X) %*% signal);
total_signal <- signal - as.vector(cbind(1, GCrate) %*% beta);



p1 <- sample[pind, 8] / rowSums(sample[pind, c(8, 9)]);
p2 <- sample[pind, 10] / rowSums(sample[pind, c(10, 11)]);


MM <- sqrt( rowSums(sample[pind,8:11]) * 0.5);


baf_signal <- abs(p1 - p2) # *  MM;




CNA.object.total <- CNA(total_signal, chr, pos, data.type = "logratio", sampleid = sampleName)

smoothed.CNA.object.total <- smooth.CNA(CNA.object.total)

segment.smoothed.CNA.object.total <- segment(smoothed.CNA.object.total, alpha=0.0001, undo.splits="prune", undo.prune = 0.01, min.width=5, verbose = 3)

pdf(file=paste(samplePath, "_total.pdf", sep=""));
plot(segment.smoothed.CNA.object.total, plot.type = "w")
dev.off();


CNA.object.as <- CNA(baf_signal, chr, pos, data.type = "logratio", sampleid = sampleName)

smoothed.CNA.object.as <- smooth.CNA(CNA.object.as)

segment.smoothed.CNA.object.as <- segment(smoothed.CNA.object.as, alpha=0.00001, undo.splits="prune", undo.prune = 0.01, min.width=2, verbose = 3)

pdf(file=paste(samplePath, "_as.pdf", sep=""));
plot(segment.smoothed.CNA.object.as, plot.type = "w")
dev.off();



