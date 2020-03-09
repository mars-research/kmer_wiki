# Feb 21

Created: Feb 21, 2020 6:04 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 24, 2020 1:43 AM

- power of 2 hashtable size (cas vs master)
16 threads
8 on one node, 8 on the other
- non-power of 2 hashtable size (cas vs master):
20 threads
10 on one node, 10 on the other
- papers:
lock free hash tables
- run a lock-free test but without prefetching so we clearly understand how it affects performance
- ustav:
numbers for jellyfish

- 8 threads in total, for equal load factors
- across numa, 16 threads in total
- across numa, 20 threads in total