#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


table <- read.table(commandArgs()[5], sep="\t",header=F);

betas <- matrix(0, length(table[,1]), 3);

# uniq tumor:9, normal:25
for (i in 1:length(table[,1])) {

	# uniq
    bases <- table[i, c(6, 7)];

    # extract two freqent alleles
    refb <- as.integer(bases[1]) - as.integer(bases[2]);
    misb <- as.integer(bases[2]);

    betas[i, 1] <- qbeta(0.1, misb + 1, refb + 1);
    betas[i, 2] <- (misb + 1) / (refb + misb + 2); 
    betas[i, 3] <- qbeta(0.9, misb + 1, refb + 1);

}


write.table(cbind( table[betas[,1] > 0.05,,drop=FALSE], betas[betas[,1] > 0.05,,drop=FALSE]), commandArgs()[6], sep="\t", row.names=F, col.names=F);






