# Feb 10

Created: Feb 10, 2020 5:01 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 11, 2020 7:03 PM

- robinhood_v2
    - check number of cache misses
    - prefetch everything
        - when you want to increment a count
            - compare if cityhash equal, if yes, prefetch datatable entry to memcmp
            - insert back into queue with tag = memcmp for increment
        - 

- cas_ht
    - atomic increments for incrementing kmer count

- overview

    ![Feb%2010/Untitled.png](Feb%2010/Untitled.png)

1. kmer (read byte-by-byte)
2. produce encoded kmer in memory in buffer
    1. decide on encoding, 3-bit or 4-bit etc. 
3. call `to_cpu()` on first 50-mer to determine the cpu it goes to 
4. enqueue kmer in the bqueue of that CPU 
    1. the kmer may not start at the byte which the pointer points to, if we encode using say a 4 bit representation). 
    2. enqueue: `struct {pointer_to_start_of_kmer, bit_offset}` 

- kmer counting:
    - treat fasta file as a concat of all sequences and count all kmers. for instance:

        ;LCBO - Prolactin precursor - Bovine
        ; a sample sequence in FASTA format
        MDSKGSSQKGSRLLLLLVVSNLLLCQGVVSTPVCPNGPGNCQVSLRDLFDRAVMVSHYIHDLSS
        EMFNEFDKRYAQGKGFIT*
        
        >MCHU - Calmodulin - Human, rabbit, bovine, rat, and chicken
        ADQLTEEQIAEFKEAFSLFDKDGDGTITTKELGTVMRSLGQNPTEAELQDMINEVDADGNGTID
        FPEFLTMMARK*
        
        >gi|5524211|gb|AAD44166.1| cytochrome b [Elephas maximus maximus]
        LCLYTHIGRNIYYGSYLYSETWNTGIMLLLITMATAFMGYVLPWGQMSFWGATVITNLFSAIPYIGTNLV
        GLMPFLHTSK

    - equivalent is:

        MDSKGSSQKGSRLLLLLVVSNLLLCQGVVSTPVCPNGPGNCQVSLRDLFDRAVMVSHYIHDLSS
        EMFNEFDKRYAQGKGFITADQLTEEQIAEFKEAFSLFDKDGDGTITTKELGTVMRSLGQNPTEAELQDMINEVDADGNGTID
        FPEFLTMMARKLCLYTHIGRNIYYGSYLYSETWNTGIMLLLITMATAFMGYVLPWGQMSFWGATVITNLFSAIPYIGTNLV
        GLMPFLHTSK

    EWIWGGFSVDKATLNRFFAFHFILPFTMVALAGVHLTFLHETGSNNPLGLTSDSDKIPFHPYYTIKDFLG
    LLILILLLLLLALLSPDMLGDPDNHMPADPLNTPLHIKPEWYFLFAYAILRSVPNKLGGVLALFLSIVIL