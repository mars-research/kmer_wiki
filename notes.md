## kmer_tbb
* **Fix `STANDALONE` segfault**  
The kmer_tbb code currenlty segfaults in `STANDALONE` mode. `STANDALONE` was for bechmarking how the code performs without 
the bqueue part. Say the numa config we are testing on has 2 nodes of 10 CPUs each. In `STANDALONE` mode, 
first `num_shards` (say 2) shards are prepared by calling `prepare_shard()` on one particular CPU of each of the 2 nodes, 
so that one shard is present on each node. Then `insert_thread()`  is called on all 20 CPUs in order.
Each `insert_thread()` thread instance uses a "chunk" of the particular shard resident on the current CPU's node's memory, 
and then inserts kmers picked out from that chunk into a hash table (each thread has its own hash table).

## bqueue
* In backtracking they do `batch_size = batch_size >> 1`; and then check if `(batch_size >=0)`. 
`batch_size` will always be >=0, so the else part will never be executed. 
And -1 will never be returned, and the buffer will never be declared empty. 
This could lead to the consumer continuing to backtrack with a batch_size of 0 and spinning.*Fixed*
```
while (!(q->data[tmp_tail])) {
		fipc_test_time_wait_ticks(CONGESTION_PENALTY);
		batch_size = batch_size >> 1;
		if( batch_size >= 0 ) {
			tmp_tail = q->tail + batch_size;
			if (tmp_tail >= QUEUE_SIZE)
				tmp_tail = 0;
		}
		else
			return -1;
	}
  ```  
  
* For some weird reason, in the code they do adaptive backtracking only if the `batch_tail` wraps around the queue, 
i.e. if  `tmp_tail >= QUEUE_SIZE`. This doesn't make sense.
```
tmp_tail = q->tail + CONS_BATCH_SIZE;
if ( tmp_tail >= QUEUE_SIZE ) {
		tmp_tail = 0;
#if defined(ADAPTIVE)
		if (q->batch_history < CONS_BATCH_SIZE) {
			q->batch_history = (CONS_BATCH_SIZE < (q->batch_history + BATCH_INCREAMENT))? CONS_BATCH_SIZE : (q->batch_history + BATCH_INCREAMENT);
		}
#endif
}
```
