# Dec 15 (observations)

Created: Jan 20, 2020 6:24 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 05, 2020 7:15 PM

Hey guys, I observed the following results are the average of all the values on the different CPUs.No inserts (only running a loop for 2000000):`Average : 32 cycles (0.066942 ms) for 2000000 insertions (0 cycles per insertion)`Returning from an insert after computing cityhash:`Average : 51867256 cycles (107163.758454 ms) for 2000000 insertions (25 cycles per insertion)`Returning from an insert after computing cityhash, memcmp with empty kmer, memcpy into bucket:`Average : 131368217 cycles (271421.953781 ms) for 2000000 insertions (65 cycles per insertion)`Returning from an insert after computing cityhash, no prefetching, memcmp with empty kmer, memcpy into bucket:`Average : 641013866 cycles (1324408.892991 ms) for 2000000 insertions (320 cycles per insertion)`Returning from an insert after computing cityhash, batch prefetching, memcmp with empty kmer, memcpy into bucket:`Average : 504122045 cycles (1041574.536463 ms) for 2000000 insertions (252 cycles per insertion)`Returning from an insert after computing cityhash, batch prefetching, using "occupied" field, memcpy into bucket:`Average : 473822723 cycles (978972.627360 ms) for 2000000 insertions (236 cycles per insertion)`Returning from an insert after computing cityhash, batch prefetching, using "occupied" field, memcpy into bucket:`Average : 473822723 cycles (978972.627360 ms) for 2000000 insertions (236 cycles per insertion)` (edited)

[4:35](https://mars-systems.slack.com/archives/CBFDEU5HT/p1576456539001100)

Observations:

- Cityhash: 25 cycles
- Memcmp + Memcpy: 65 cycles
- Replacing memcmp with a byte comparison using an "occupied" field saves 18 cycles
- Total with prefetch: 252 cycles (320 cycles without prefetch)
- Average number of insertions leading to reprobes: 629309 of 2000000 = 30%