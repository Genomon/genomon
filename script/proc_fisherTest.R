#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


table <- read.table(commandArgs()[5], sep="\t",header=F);

pvalues <- rep(0, length(table[,1]));

# uniq tumor:9, normal:25
for (i in 1:length(table[,1])) {

	# uniq
    tumor <- table[i, c(6, 7, 8, 9)];
	normal <- table[i, c(13, 14, 15, 16)];


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


	Fmatrix <- matrix(as.integer(c(tumor[ind1], normal[ind1], tumor[ind2], normal[ind2])), 2, 2);
	pvalues[i] <- fisher.test(Fmatrix)$p.value;

}


my_trans <- function(x = 0) {
	return( max(0, -log10(x)));
}


kekka <- apply(as.matrix(pvalues), c(1,2), my_trans);
write.table(cbind(table[kekka > -log10(0.05),], kekka[kekka > -log10(0.05)]), commandArgs()[6], sep="\t", row.names=F, col.names=F);






