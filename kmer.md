# KMer Counting

## Counting KMers
Sliding window of size K over the sequence. Discard all windows that contain a character not in the alphabet, such as `N`.

## DNA alphabets
There're 4 characters in the DNA alphabet, {A, C, G, T}. To represent a DNA KMer in memory, 2 bits are needed for each mer. 
You can read more about this in the section 4.1 of the [2019 Kmerind paper](https://github.com/mars-research/kmer_wiki/blob/master/papers/bioinformatics/kmerind-acm-tcbb.pdf).

## Canonical mode
DNA is double stranded with two strand running in different direction. Therefore, each kmer has its reverse couter part on the other strand.
You can also read more about this in the section 4.1 of the 2019 Kmerind paper.

## Performance
To calculate the performance of a kmer counting tool in terms of cycles per kmer per core, the equation is `time(cycles) / num_kmers * num_cores`.
