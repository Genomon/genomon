#  Copyright Human Genome Center, Institute of Medical Science, the University of Tokyo
#  @since 2012

MeanAlleleCount <- function(count = c(1, 1, 1, 1)) {

    p1 <- count[1,1] / (count[1,1] + count[1,2]);
    p2 <- count[1,3] / (count[1,3] + count[1,4]);

   for (n in 1:10) {

        # E-step
        R <- rep(0, length(count[,1]));
        for (i in 1:length(count[,1])) {
            tq1 <- count[i,1] * log(p1) + count[i,2] * log(1 - p1);
            tq1 <- tq1 + count[i,3] * log(p2) + count[i,2] * log(1 - p2);

            tq2 <- count[i,1] * log(1 - p1) + count[i,2] * log(p1);
            tq2 <- tq2 + count[i,3] * log(1 - p2) + count[i,2] * log(p2);

            tq1 <- tq1 - min(tq1, tq2);
            tq2 <- tq2 - min(tq1, tq2);
 
            tempR <- c(exp(tq1), exp(tq2));
            R[i] <- tempR[1] / sum(tempR);
        }

        # £ø-step
        p1 <- sum(R * count[,1] + (1 - R) * count[,2]) / sum(count[,1:2]);
        p2 <- sum(R * count[,3] + (1 - R) * count[,4]) / sum(count[,3:4]);

    }

    tempRes <- c(mean(R * count[,1] + (1 - R) * count[,2]));
    tempRes <- c(tempRes, mean(R * count[,2] + (1 - R) * count[,1]));
    tempRes <- c(tempRes, mean(R * count[,3] + (1 - R) * count[,4]));
    tempRes <- c(tempRes, mean(R * count[,4] + (1 - R) * count[,3]));

    return(ceiling(tempRes));

}


bait2as_count <- read.table(commandArgs()[5], sep="\t", header=F);

tempStart <- bait2as_count[1,2];
tempCount <- matrix(0, 0, 4);
outputData <- matrix(0, 40000, 7);

nID <- 1;
for (n in 1:length(bait2as_count[,1])) {


	if (bait2as_count[n,2] != tempStart) {

		if (length(tempCount[,1]) > 1) {
			tCount <- MeanAlleleCount(tempCount);
		} else {
			tCount <- tempCount[1,];
		}

		outputData[nID, 1] <- as.character(tempChr);
		outputData[nID, 2] <- tempStart;
		outputData[nID, 3] <- tempEnd;
		outputData[nID, 4:7] <- as.numeric(tCount);

		nID <- nID + 1;
		tempCount <- matrix(0, 0, 4);
	}

	tempChr <- bait2as_count[n,1];
	tempStart <- bait2as_count[n,2];
	tempEnd <- bait2as_count[n,3];

	tempCount <- rbind(tempCount, bait2as_count[n,10:13]);


}

write.table(outputData[outputData[,1]!=0,], commandArgs()[6], sep="\t", row.names=F, col.names=F);


