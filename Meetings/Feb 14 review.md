# Feb 14 (review)

Created: Feb 17, 2020 6:09 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 19, 2020 2:02 PM

---

Anton + Vikram

---

- although no. of cycles reduces, cache misses increases (no prefetch vs. prefetch for memcmp)
    - prefetch might also be counted as cache misses
    - EXPT:
        - loop, prefetch and see if it is counted as misses
        - hardware is also clever, so check (maybe already have this?)
- infra for monitoring cache lines?
- we need some reliable of measuring number of cache misses.
- perf:
    - fine grained perf vs. coarse grained perf
        - how to do this? syscall to drop into kernel.
        - we have to see entire statistics
    - how much time in application vs. kernel, kernel pollutes cache, but effect should be the same across all the cases
    - repeat runs
    - drop caches not needed
- lot of variabliities:
irq getting rebalanced, moving to another cpu (but we are pinning), acidentally crossing numa
- l1 vs llc misses
    - l1 doesn't make sense to look at
    - look at l3 misses
- expt idea:
giant array, don't touch memory, just prefetch
prefetch is prefetch, it doesn't know whether you are going to r/w into cachel
- size of the queue experiments:
20 x 64 bytes
L3 is quite expensive, L2 is better
- differentiate prefetch cache misses from other misses
    - docs are incomprenshible, need to look into it
- original is better than robinhood for inserts
    - two tables (pointertable, hashtable) fighting for cache, so robhinhod is slow
    - robinhood seems to be better for finds, not for inserts (inserts, we take more cycles due to swapping)
    - we don't have that many lookups because in general, because most of the kmers appear only once => increase number of repetitions in dataset to figure out.
- lock-free seems to perform well enough
    - EXPT:
        - measure the cost of atomic increments in a loop
            - increment some value in a loop of million and measure
            - do CAS on a value with lock prefix million times and see what's the number without contention
        - replace CAS with FADI to see if numbers go up
        - objdump with -S to see if CAS is being used
        CMPXCH instruction (search for this)
        - forcefully touch the cache line containing the counter on other cores, and see how long it takes (cache bounce)
    - 64 bit CAS or 128 bit CAS?
    128 bit migth have ABA problems? (ABA is when you deallocate memory and reallocate again, only when there is pointers)
    - maybe it doesn't really lock the bus if this cache line isn't available on the othr caches? maybe it just can reorder instructions effectively. The cas increment can be delayed?
    - for locking a cache line to CAS, what are the steps needed to be peformed wrt coherence?
        - invalidate the cache line on other cores (probably doens't take many cycles)
        - you don't need to lock the bus?
        - check other paper about synchronization (lock operations add minor overhead compared to cache transactions). But during no contention scenario?
        - it just moves forward, later it finishes?
- EXPT:
    - Do it for 90 % load as well, CAS
- EXPT:
    - numbers form jellyfish
    - partitioning argument doesn't make much sense then?
- Vikram paper on channel.
    - cache line should be read exclusive state for CAS?
    - only if cache line is in shared state there is a latency of 30ns = ~80 cycles. in our case there is no shard state.
    - exclusive state is 5ns (l1), 20ns (l3) = 50 cycles

---

Vikram discussion

---

- how RNA's are distributed (same poisson?)
    - can we compete for rna analysis?
- jellyfish also does other optimizations
- matrix multiplications
- storing duplicate data, then sorting
- ours is probably an underestimate of what they are doing
- try intel tbb (state of the art concurrent hash table)
    - one big map, multiple threads
    - no compare and swap, their insert is thread-safe
- perf:
    - granular perf?
    - measure between these two code sections?
- almost all loads are misses, why? 6 million (non-robinhood) vs 17 million for robinhood
- even with prefetching we are able to save only 2 million load misses?: llc loads vs llc load-misses.
- almost 4 mill is missed.
- EXPT:
    - perf numbers for no prefeching for non-robinhood without prefetching. put it in the queue and don't do anything.
        - 353 cycles without prefetch at 94% load
        - 270 cycles with prefetch at 94% load

perf
repeat
update linux
perf list