
Debug BQueues [Anton/Vikram]
-----------------------------


YCSB [Michael]
--------------

 - YCSB - real benchmarking suit for real workloads, because both uniform and
   skewed are synthetic 

[Vikarm] 
---------

 - Fix the skewed distribution so we can take a look at the real numbers (maybe
   even enable partitioned mode under some conditions)

[Vikram/Daman] 
--------------

- Clean up the code to plug in different kv sizes and algorithms

[Daman/Vikram] 
--------------

- We need to dynamically create consumer (delegation) threads, if the
  proportion of writes goes up we need to create more [Daman] -- otherwise we
suck on growing number of writes

- We need to re-balance the partitions to distribute the load proportionally
  [Vikram] --- otherwise we suck on skew 

  -- Mapping of partitions to threads and change it dynamically [comes from
consistent hashing]

Plot DRAM Bandwidth
-------------------------

- Add bandwidth to the plots

Add the plot for tail latency
------------------------------


Microbenchmarks
--------------------

- Hash join (run to see the results) [Niv]

-- We should add some real tables along with <8B, 8B>, e.g., <256B, 1024B>

- Aggregation (add aggregation on 20 byte keys -- matches genomic workloads)

Macrobenchmark
-----------------

 - KV store over the network via DPDK (Mica-like kv-store), compare agains
   Mica?
