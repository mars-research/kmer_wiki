# May 1

Created: May 2, 2020 2:16 PM
Created By: Harishankar Vishwanathan
Last Edited Time: May 2, 2020 2:23 PM

### GZIP/BZIP decompression using SIMD

- Discussed gzip/bzip with Yang
    - [https://catchchallenger.first-world.info/wiki/Quick_Benchmark:_Gzip_vs_Bzip2_vs_LZMA_vs_XZ_vs_LZ4_vs_LZO](https://catchchallenger.first-world.info/wiki/Quick_Benchmark:_Gzip_vs_Bzip2_vs_LZMA_vs_XZ_vs_LZ4_vs_LZO)
    - [http://www.brutaldeluxe.fr/products/crossdevtools/lz4/index.html](http://www.brutaldeluxe.fr/products/crossdevtools/lz4/index.html)
    - [https://quixdb.github.io/squash-benchmark/unstable/](https://quixdb.github.io/squash-benchmark/unstable/)

- Anton:
    - ok, I read through parallel gzip, and I think it's not our cup of tea --- in the end even parallel decompression is slow (slower than NVMe), I guess we should take a position that on the modern hardware (NVMe + enought DRAM) genomic workloads have to switch to a better compression algorithm (we should suggest which one, so have to do a literature search), but I guess we'll work with decompressed data
    - parallel gzip is too complicated to build, and doesn't solve the problem.... I guess DEFLATE itself is slowish

### KMC3/gerbil discussion

- Look at Gerbil's source to see how they do parsing
- Get proper numbers for yu's parser and kseq
- Decide with Yang and Yu about alotment of work:
    - Encoding
    - Parsing

- Still not worked out how k,x mers work. Have to read KMC3