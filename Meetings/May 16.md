# May 16

Created: May 17, 2020 4:49 PM
Created By: Harishankar Vishwanathan
Last Edited Time: May 17, 2020 4:53 PM

- try perf (differential debugging)
    - look at pagefaults to check if what?
- Compare AIO vs fread (single threaded first, then multithreaded)
    - read a dataset and compare.
- Anton's idea: 2 AIO threads pumping data into 10 hashtable threads buffers. This should be enough. 2, 10 are configurable, but IO will be faster than consumption.
- strace
    - Jacob Sorber