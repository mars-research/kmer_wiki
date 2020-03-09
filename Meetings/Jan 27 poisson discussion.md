# Jan 27 (poisson discussion)

Created: Feb 05, 2020 7:10 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 05, 2020 7:15 PM

- A very decent short introductory article explaining coverage, genome size, and total no. of kmers and the relation between them: [https://bioinformatics.uconn.edu/genome-size-estimation-tutorial/](https://bioinformatics.uconn.edu/genome-size-estimation-tutorial/#)

![Jan%2027%20poisson%20discussion/Untitled.png](Jan%2027%20poisson%20discussion/Untitled.png)

- This is a typical histogram. X axis (number of times a kmer is observed, i.e frequency) vs. Y axis (total number of kmers with a given frequency)
- Re: our discussion last week. There are large number of kmers which appear only once (at X = 1), these are due to sequencing errors. kmers should not appear only once especially when sequencing coverage C is high. (edited)
- I was thinking our synthetic data generation doesn't seem to resemble the above typical histogram. The distribution of data in a typical sequence is a Poisson distribution (with an added extra peak at 1 due to sequencing errors). I don't know what ours should be called, but it definitely does not resemble the above graph. (edited)
- For instance, this is what our distribution is (numbers rounded to make it meaningful):

    frequency : total number of kmers / 10e3
    1    270
    2    271
    3    180
    4    90
    5    36
    6    12
    7    3
    8    1
    9    0
    10    0
    11    0
    12    0

- And this is what the "typical distribution" gives, from the link i sent:

    frequency : total number of kmers / 10e3
    1        130
    2        32
    3        39
    4        54
    5        71
    6        89
    7        105
    8        119
    9        133
    10        144
    11        152
    12        156
    13        154
    14        147
    15        134
    16        118
    17        100
    18        82
    19        65
    20        50
    21        38
    22        28
    23        21
    24        15
    25        11

- You can see the peaks at 1, and around 12 in the second dataset. Whereas in the first dataset (ours), there is a peak only at 1 (edited) . Shouldn't we try to make our dataset also representative of the typical datasets?
- [vikram](https://mars-systems.slack.com/team/U2QFH3YKZ) what was the rationale behind the generation of the dataset in the particular way as it is currently: Nothing in particular. we were mostly working with random data and optimizing bqueues. haven't seen real data