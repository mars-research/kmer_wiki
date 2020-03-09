# Jan 24

Created: Jan 27, 2020 4:41 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 05, 2020 7:58 PM

- Currently: 40% of HT is full, of 2M kmers, 1M are unique. It is a luxury to have a power of 2 HT, or even 40% full HT
- Proposal: only as table gets saturated, and there is more collisions, more reprobes, effect of robinhood gives us advantage. (TODO)
- Proposal: Storing hash in HT, Robinhood, have their advantages only when table is full.
- Since, most kmers show up only once, we will lookup find they are not in the HT and insert.

- Benchmark of major HT implementations

[Benchmark of major hash maps implementations](https://tessil.github.io/2016/08/29/benchmark-hopscotch-map.html)

- Best speed in above benchmarks:
    - 3M/0.65 sec at 0.72 load factor ⇒ 4.6M insertions / sec.
    - ⇒ 4.6M insertions in 2.2 * 10^9 cycles (2.2 Ghz)
    - ⇒ 478 cycles per insertion
- Build a similar HT that uses prefetch + CAS + multithreaded. To check what if we use prefetch and put it inside jellyfish, can it be better than our partiitoned HT?
    - Builid JF-like HT. no invertible matrices etc. now. mainly prefetch
- Locking primitives are twices as slow as CAS.

- IDEA: we will say Intel TBB is 400 cycles, Lock-free is 200 cycles, ours is 100 cycles.