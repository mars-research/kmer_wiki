
# 2022-05-04
----

* With a small hashtable that would fit in the L2 cache
  - partitioned hashtable (no bqueues, no prefetch-engine, monotonic counters) take ~25 cycles
  ```
  cmake -DPREFETCH=OFF ../
  ./kvstore --mode 6 --ht-size 65536 --ht-type 1 --numa-split 1 --num-threads 1 --insert-factor 300
  Average  : 375840560 cycles (170.836623 ms) for 14745600 insertions (25 cycles/insert) (fill = 75 %)
  ```

  - casht++ (with prefetch-engine) takes
  ```
  cmake ../
  ./kvstore --mode 6 --ht-size 65536 --ht-type 3 --numa-split 1 --num-threads 1 --insert-factor 300
  Average  : 845462314 cycles (384.301063 ms) for 14745600 insertions (57 cycles/insert) (fill = 75 %)

  ```

* For some unknown reason, looking up values in the zipfian generated vector adds
  an overhead of 40 cycles on a single threaded test.
  ```
  # partitioned
  ./kvstore --mode 11 --ht-size 65536 --ht-type 1 --numa-split 1 --num-threads 1 --insert-factor 300
  Average  : 3162652 cycles (1.437569 ms) for 49152 insertions (64 cycles/insert) (fill = 75 %)

  # casht++
  ./kvstore --mode 11 --ht-size 65536 --ht-type 3 --numa-split 1 --num-threads 1 --insert-factor 300
  Average  : 4492810 cycles (2.042186 ms) for 49152 insertions (91 cycles/insert) (fill = 75 %)
  ```

* With bqueues, on a 32-32 configuration (no prefetch-engine, monotonic counters)
  - The hashtable size of 32 MB fits in the L2 cache
  ```
  ./kvstore --mode 8 --ht-size $((65536 * 32)) --nprod 32 --ncons 32 --insert-factor 300
  Average  : 365804173 cycles (166.274629 ms) for 7372864 insertions (49 cycles/insert) (fill = 75 %)
  Number of insertions per sec (Mops/s): 1697.959
  ```

* casht++ on 64 threads
  ```
  ./kvstore --mode 6 --ht-size $((65536 * 32)) --num-threads 64 --insert-factor 100 --ht-type 3 --numa-split 1
  Average  : 182750375 cycles (83.068355 ms) for 2457600 insertions (74 cycles/insert) (fill = 75 %)
  Number of insertions per sec (Mops/s): 2248.649
  ```

# 2022-05-05
----
* Raw section queue test with no insertions averages at ~25 cycles for equal
  number of prod-cons.

* Zipfian insertions take an additional 40 cycles of overhead compared to
  monotonic. It turns out that zipfian distribution incurs a lot of reprobes
  compared to a monotonic counter (where the reprobe count is 0).
  ```
  # casht++ - zipfian
  2022-05-05 14:53:42.048 INFO  [1142848] [kmercounter::ZipfianTest::run@134] Reprobes 591788 soft_reprobes 1775456
  Thread  0: 156681738 cycles (71.218974 ms) for 1572864 insertions (99 cycles/insert) | (0 cycles/enqueue)
  Average  : 156681738 cycles (71.218974 ms) for 1572864 insertions (99 cycles/insert) (fill = 75 %)
  # casht++ - monotonic
  reprobes 0 soft_reprobes 0
  ```
  - For inserting 1572864 elements, we reprobe (591788 + 1775456) times. i.e., 1.5 reprobes per insertion.
  ```
  >>> (591788 + 1775456) / 1572864
  1.505053202311198
  ```

# 2022-05-06

* Branched vs SIMD comparison
  * Branched - no bqueues, zipfian
    - num-threads=1
      ```
      ./kvstore --mode 11 --ht-type 1 --ht-size 2097152 --numa-split 1 --insert-factor 100 --skew 0.01
      Average  : 12489652064 cycles (5677.114744 ms) for 157286400 insertions (79 cycles/insert) (fill = 75 %)
      ```
    - num-threads=32
      ```
      ./kvstore --mode 11 --ht-type 1 --ht-size 2097152 --numa-split 1 --num-threads 32 --insert-factor 100 --skew 0.01
      Average  : 103158423 cycles (46.890194 ms) for 1228800 insertions (83 cycles/insert) (fill = 75 %)
      ```
  * Branched - large-ht
    - num-threads=32
    ```
    ./kvstore --mode 11 --ht-type 1 --numa-split 1 --num-threads 32 --skew 0.01
    Average  : 9254886931 cycles (4206.766913 ms) for 100663296 insertions (91 cycles/insert) (fill = 75 %)
    ```

  * SIMD - no bqueues
    - num-threads=1
      ```
      cmake -DBRANCH=simd ..
      ./kvstore --mode 11 --ht-type 1 --ht-size 2097152 --numa-split 1 --insert-factor 100 --skew 0.01
      Average  : 13426848564 cycles (6103.113166 ms) for 157286400 insertions (85 cycles/insert) (fill = 75 %)
      ```
    - num-threads=32
      ```
      cmake -DBRANCH=simd ..
      ./kvstore --mode 11 --ht-type 1 --ht-size 2097152 --numa-split 1  --insert-factor 100 --skew 0.01 --num-threads 32
      Average  : 445292157 cycles (202.405532 ms) for 4915200 insertions (90 cycles/insert) (fill = 75 %)
      ```
  * on 64 threads, simd
    ```
    cmake -DBRANCH=simd ..
    ./kvstore --mode 6 --ht-type 1 --numa-split 1 --num-threads 64
    ===============================================================
    Average  : 5937817951 cycles (2699.008240 ms) for 50331648 insertions (117 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 380020348900 cycles (172736.527375 ms) for 3221225472 insertions
    ===============================================================
    Average  : 5073348027 cycles for 50331632 finds (100 cycles/find)
    ===============================================================
    ```

  * on 64 threads, branched
    ```
    cmake -DBRANCH=branched ..
    ./kvstore --mode 6 --ht-type 1 --numa-split 1 --num-threads 64
    ===============================================================
    Average  : 5818612718 cycles (2644.824042 ms) for 50331648 insertions (115 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 372391213972 cycles (169268.738668 ms) for 3221225472 insertions
    ===============================================================
    Average  : 3332495285 cycles for 50331632 finds (66 cycles/find)
    ===============================================================
    ```

  * on 32 threads, branched
    ```
    ===============================================================
    Average  : 6126409706 cycles (2784.731768 ms) for 100663296 insertions (60 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 196045110606 cycles (89111.416568 ms) for 3221225472 insertions
    ===============================================================
    Average  : 4636403391 cycles for 100663280 finds (46 cycles/find)
    ===============================================================
    Number of insertions per sec (Mops/s): 1386.667
    print_stats, num_threads 32
    Number of finds per sec (Mops/s): 1808.696
    { insertion: 1386.667 lookup: 1808.696 }
    ===============================================================
    ```

  * on 32 threads, simd
    ```
    ===============================================================
    Average  : 7717672179 cycles (3508.032913 ms) for 100663296 insertions (76 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 246965509750 cycles (112257.053232 ms) for 3221225472 insertions
    ===============================================================
    Average  : 9634681671 cycles for 100663280 finds (95 cycles/find)
    ===============================================================
    Number of insertions per sec (Mops/s): 1094.737
    print_stats, num_threads 32
    Number of finds per sec (Mops/s): 875.789
    { insertion: 1094.737 lookup: 875.789 }
    ===============================================================
    ```

  * on 32 threads, branched - zipfian
    ```
    ===============================================================
    Average  : 9251769809 cycles (4205.350039 ms) for 100663296 insertions (91 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 296056633914 cycles (134571.201244 ms) for 3221225472 insertions
    ===============================================================
    Average  : 0 cycles for 1 finds (0 cycles/find)
    ===============================================================
    Number of insertions per sec (Mops/s): 914.286
    print_stats, num_threads 32
    Number of finds per sec (Mops/s): inf
    { insertion: 914.286 lookup: inf }
    ===============================================================
    ```

  * on 16 threads, branched - zipfian
    ```
    ===============================================================
    Average  : 16959901463 cycles (7709.046350 ms) for 201326592 insertions (84 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 271358423416 cycles (123344.741592 ms) for 3221225472 insertions
    ===============================================================
    Average  : 0 cycles for 1 finds (0 cycles/find)
    ===============================================================
    Number of insertions per sec (Mops/s): 495.238
    print_stats, num_threads 16
    Number of finds per sec (Mops/s): inf
    { insertion: 495.238 lookup: inf }
    ===============================================================
    ```

  * on 16 threads, simd - zipfian
    ```
    ===============================================================
    Average  : 18221473646 cycles (8282.488268 ms) for 201326592 insertions (90 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 291543578346 cycles (132519.812288 ms) for 3221225472 insertions
    ===============================================================
    Average  : 0 cycles for 1 finds (0 cycles/find)
    ===============================================================
    Number of insertions per sec (Mops/s): 462.222
    print_stats, num_threads 16
    Number of finds per sec (Mops/s): inf
    { insertion: 462.222 lookup: inf }
    ===============================================================
    ```

  * on 32 threads, simd - zipfian
    ```
    ===============================================================
    Average  : 9453854016 cycles (4297.206499 ms) for 100663296 insertions (93 cycles/insert) (fill = 75 %)
    ===============================================================
    Total  : 302523328538 cycles (137510.607979 ms) for 3221225472 insertions
    ===============================================================
    Average  : 0 cycles for 1 finds (0 cycles/find)
    ===============================================================
    Number of insertions per sec (Mops/s): 894.624
    print_stats, num_threads 32
    Number of finds per sec (Mops/s): inf
    { insertion: 894.624 lookup: inf }
    ===============================================================
    ```

* Prefetch engine overhead
  - For insertions,
    - Cashtpp + prefetch-engine
      ```
      ./kvstore --mode 11 --ht-type 3 --ht-size 2048 --numa-split 1 --insert-factor 300 --no-prefetch 0
      Average  : 13326252 cycles (6.057387 ms) for 230400 insertions (57 cycles/insert) (fill = 75 %)
      ```
    - Cashtpp + no-prefetch
      ```
      ./kvstore --mode 11 --ht-type 3 --ht-size 2048  --numa-split 1 --no-prefetch 1 --insert-factor 300
      Average  : 11597000 cycles (5.271364 ms) for 230400 insertions (50 cycles/insert) (fill = 75 %)
      ```

# TODOs
---
  - [x] perform raw section queue test - no insertions

  - [x] investigate why zipfian vector read takes 40 cycles

  - [x] investigate optimal prefetch distance for casht++ and partitioned (small HT)

  - investigate bi-modality on casht++ (64 threads)

  - [x] Compare SIMD vs branched
    - [x] validate SIMD configuration
    - [x] on both small and large HT
    - put some of the code back into an if block to avoid writing cachelines again

  - fix vtune for small-ht measurements
    - vtune doesn't show queue overhead
  - Design an experiment to measure the overhead of prefetch engine
    - Measure with and without prefetch engine and compute the difference on a single-threaded experiment
    - ideally to find out why 1.5 reprobes take 40 additional cycles
