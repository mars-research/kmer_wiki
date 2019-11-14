### Lamport Queue
* head(tail) are incremented by producer(consumer) after every insert(remove). 
* cache line containing head and tail are frequently invalidated. 
* only works on sequential consistency memory model.

### FastForward
* buffer/queue is initially all `NULL`s. 
* control variables `head(tail)` are local to producer(consumer), and comparison to `NULL` is used to enqueue(dequeue).
* If slot at head is `NULL`, producer can insert. If slot at tail is full, consumer can remove.
* if consumer and producer are very close to each other, `buffer[head]` accessed by producer to enqueue and `buffer[tail]` 
accessed by consumer to dequeue could be located on the same cache-line, causing the cache-line to bounce between 
producer and consumer. 
* `NULL` is used for control, so it cannot be used as data.

### MCSRingBuffer 
* `actualHead`, `actualTail` are shared global variables between producer and consumer. 
* producer uses `localHead`, `tailEstimate` for most insert operations. producer writes to `localHead` only. 
only after `BATCH_SIZE` inserts, `actualHead` is made equal to current `localHead` 
(`actualHead` catches up once every `BATCH_SIZE` inserts, and is generally always behind `localHead`). 
* While inserting, if `NEXT(localHead) == tailEstimate`, queue is *possibly* full. So check if `NEXT(localHead) == actualTail`.
If yes queue is *actually* full. If not update estimate of `localTail = actualTail` and continue insert.  
* reduces frequency of producer to read the actual tail `actualTail`, and write to actual head, `actualHead`. 
* if producer is less than `BATCH_SIZE` ahead of consumer, consumer will be blocked, even if buffer is not empty. 
* control variables are not on queue, `NULL` can be used as data. 
* batching improves the performance, but makes the algorithm prone to deadlock (t1 <=> t2 synchronization situation, when 
t1 generates data less than `BATCH_SIZE`, t2 generates feedback less than `BATCH_SIZE`)

### Bqueue
* only local control variables are used: `head` and `batchHead` by producer, `tail` and `batchTail` by consumer. 
* Producer: 
  * `batchHead` is usually `BATCH_SIZE` ahead of `head`. Slots between `head` and `batchHead` are safe to insert. 
  * Only if there are `BATCH_SIZE` slots ahead of `head` that are empty (NULL), the producer *starts* inserting at `buffer[head]` 
(and increments `head`). It continues inserting until `head == batchHead`. 
  * Once `head == batchHead`, probe `BATCH_SIZE` slots ahead (make `batchHead = batchHead + BATCH_SIZE`, and check if `buffer[BATCH_SIZE == NULL`) to see if that slot is empty. 
This means all slots between `head` and `batchHead` are empty. Only then start inserting. 
  * `head` catches up with `batchHead` once every `BATCH_SIZE` inserts => slow path. Else it is always on the fast path. If 
`BATCH_SIZE` is a multiple of cache-line size, cache trashing never occurs on the fast path. 
  * batching allows producer and consumer to detect a batch of available slots at a tie, reducing the no. of shared memory accesses. 
* Consumer: 
  * Slots between `tail` and `batchTail` are safe to remove. 
  * Symmetrically, we would do: Only if there are `BATCH_SIZE` slots ahead of `tail` that are full, consumer *starts* removing. However, note that this is the problem with MCSRingBuffer. If
slot at `tail + BATCH_SIZE` is not full, then 1.) wait for a few ticks, to allow producer to get ahead, 2.) check if 
`buffer[(tail + BATCH_SIZE)/2]` is full. If not check if `buffer[(tail + BATCH_SIZE)/4]` is full, and so on. 
  * Guarantees that consumer progresses as long as producer has produced some data, taking `log(2)BATCH_SIZE` memory accesses 
in the worst case. 
