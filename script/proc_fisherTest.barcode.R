#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


table <- read.table(commandArgs()[5], sep="\t",header=F);

betas <- matrix(0, length(table[,1]), 3);

# uniq tumor:9, normal:25
for (i in 1:length(table[,1])) {

	# uniq
    bases <- table[i, c(6, 7, 8, 9)];

    # extract two freqent alleles
    ref <- table[i, 3];
    alt <- table[i, 4];

    ind1 <- 0;
    if (ref == "A" || ref == "a") {
        ind1 <- 1;
    } else if (ref == "C" || ref == "c") {
        ind1 <- 2;
    } else if (ref == "G" || ref == "g") {
        ind1 <- 3;
    } else {
        ind1 <- 4;
    }

    ind2 <- 0;
    if (alt == "A" || alt == "a") {
        ind2 <- 1;
    } else if (alt == "C" || alt == "c") {

        ind2 <- 2;
    } else if (alt == "G" || alt == "g") {
        ind2 <- 3;
    } else {
        ind2 <- 4;
    }

    refb <- as.integer(bases[ind1]);
    misb <- as.integer(bases[ind2]);

    betas[i, 1] <- qbeta(0.1, misb + 1, refb + 1);
    betas[i, 2] <- (misb + 1) / (refb + misb + 2); 
    betas[i, 3] <- qbeta(0.9, misb + 1, refb + 1);

}


write.table(cbind( table[betas[,1] > 0.05,,drop=FALSE], betas[betas[,1] > 0.05,,drop=FALSE]), commandArgs()[6], sep="\t", row.names=F, col.names=F);






