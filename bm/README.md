Run the same benchmarks with each GoAWK build:

The script requires the bitwise operator syntax from `goawk-xonixx` to parse,
even when selecting only arithmetic benchmarks.

```sh
/path/to/goawk-old -f bm/bm.awk -- -n 10000000 -b inc,add_float
/path/to/goawk-new -f bm/bm.awk -- -n 10000000 -b inc,add_float
```

Omit `-b` to run all benchmarks. Use `--list` for names and `--help` for
options. Each benchmark has its own `bm_*` function and runs exactly `-n`
iterations. Each nonempty loop body performs ten operations. Selection order
is preserved. Output includes elapsed seconds, net nanoseconds per operation
(`ns/op`), and the final result.

`ns/op` is `(elapsed - empty_elapsed) * 1e9 / (iterations * 10)`.
The empty-loop baseline is measured once before the selected benchmarks,
even when `empty` is not selected. Its measurement is reused for any `empty`
rows, whose net time is zero. Negative net times are retained to show timing
noise rather than clamped to zero.

Bitwise benchmarks use int64 operands and cover `&`, `|`, `^` (XOR), `~`
(complement), `<<`, `>>` (signed right shift), and `>>>` (unsigned right shift).
Their names are `bit_and`, `bit_or`, `bit_xor`, `bit_not`, `bit_lshift`,
`bit_rshift`, and `bit_urshift`. Each binary operator also has a corresponding
`_assign` benchmark for its compound assignment form (including `>>>=`).
Repeated shifts eventually produce 0 or -1; the VM continues executing all ten
operations per iteration.

Timing reads the first field of Linux `/proc/uptime`, with 0.01-second
resolution. The file is reopened for each reading. Reported times include
loop overhead, function dispatch, and clock-read overhead;
they are wall-clock measurements, not isolated CPU instruction timings.
Use enough iterations for each benchmark to take at least a second, and repeat
runs to assess noise. Elapsed seconds include the loop baseline; `ns/op`
subtracts it to estimate the cost of the operations. Output occurs outside
the timed loops.

To add an operation, add a `bm_*` function with ten operations per iteration,
its name to `Available` in `BEGIN`, and a dispatch branch in `run_benchmark`.

### Reproducible benchmarking

`taskset -c 17 ./goawk -f /path/to/bm.awk -- -n 20000000`
