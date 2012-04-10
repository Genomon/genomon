#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012


table <- read.table(commandArgs()[5], sep="\t",header=F);

pvalues <- rep(0, length(table[,1]));

for (i in 1:length(table[,1])) {

	# uniq
    tumor <- table[i, c(6, 7)];
	normal <- table[i, c(10, 11)];


	Fmatrix <- matrix(as.integer(c(tumor[1] - tumor[2], tumor[2], normal[1] - normal[2], normal[2])), 2, 2);
	pvalues[i] <- fisher.test(Fmatrix)$p.value;

}


my_trans <- function(x = 0) {
	return( max(0, -log10(x)));
}


kekka <- apply(as.matrix(pvalues), c(1,2), my_trans);
write.table(cbind(table[kekka > -log10(0.05),], kekka[kekka > -log10(0.05)]), commandArgs()[6], sep="\t", row.names=F, col.names=F);






