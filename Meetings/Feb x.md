# Feb x

Created: Feb 06, 2020 10:22 PM
Created By: Harishankar Vishwanathan
Last Edited Time: Feb 15, 2020 1:46 AM

- dereference is slower than assignment (`__insert_and_swap`)?
    - In robinhood v2, we derefrence
- find take more cycles robinhood v2 (900) > robinhood (530) > master (420) when ht is 90% full.
    - due to dereference?
    - why robinhood is slower than master, even with less distance from bucket on max case? avergae distance from bucket is same.

- CAS ht
    - Strategy:
        - create kmer data on multiple threads
        - one global hashtable
        - insert:
            - prefetch 20 inserts
            - after 20: while compare and swap not success, reprobe
    - Questions:
        - max reprobe?
        - quadratic probing?
        - 

    - Results:
        - mutex per bucket insert/find: 380 cycles / 270 cycles
        - CAS on occupied bool insert/find: 142 cycles / 236 cycles

- block store
    - only root has rwe access to the block store,
    - tried to create

 

- other project?
- Spring break

- atomic increment
- prefetch everything in robinhood v2
- try master with no prefetch (why??)