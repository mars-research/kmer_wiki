
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

# TODOs
---
  - [x] perform raw section queue test - no insertions

  - [x] investigate why zipfian vector read takes 40 cycles

  - investigate optimal prefetch distance for casht++ and partitioned (small HT)
  - investigate bi-modality on casht++ (64 threads)
  - Compare SIMD vs branched
    - validate SIMD configuration
    - on both small and large HT
  - fix vtune for small-ht measurements
    - vtune doesn't show queue overhead
  - Design an experiment to measure the overhead of prefetch engine
    - Measure with and without prefetch engine and compute the difference on a single-threaded experiment
    - ideally to find out why 1.5 reprobes take 40 additional cycles
