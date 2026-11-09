Run the same benchmarks with each GoAWK build:

```sh
/path/to/goawk-old -f bm/bm.awk -- -n 10000000 -b inc,add_float
/path/to/goawk-new -f bm/bm.awk -- -n 10000000 -b inc,add_float
```

Omit `-b` to run all benchmarks. Use `--list` for names and `--help` for
options. Each benchmark has its own `bm_*` function and runs exactly `-n`
iterations. Each nonempty loop body performs ten operations. Selection order
is preserved. Output includes elapsed seconds, raw nanoseconds per iteration
(`ns/iter`), net nanoseconds per operation (`net ns/op`), and the final result.

`net ns/op` is `(elapsed - empty_elapsed) * 1e9 / (iterations * 10)`.
The empty-loop baseline is measured once before the selected benchmarks,
even when `empty` is not selected. Its measurement is reused for any `empty`
rows, whose net time is zero. Negative net times are retained to show timing
noise rather than clamped to zero.

Timing reads the first field of Linux `/proc/uptime`, with 0.01-second
resolution. The file is reopened for each reading. Reported times include
loop overhead, function dispatch, and clock-read overhead;
they are wall-clock measurements, not isolated CPU instruction timings.
Use enough iterations for each benchmark to take at least a second, and repeat
runs to assess noise. Raw times include the loop baseline; `net ns/op`
subtracts it to estimate the cost of the operations. Output occurs outside
the timed loops.

To add an operation, add a `bm_*` function with ten operations per iteration,
its name to `available` in `bm`, and a dispatch branch in `run_benchmark`.
