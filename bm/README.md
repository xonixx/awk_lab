Run the same benchmarks with each GoAWK build:

```sh
/path/to/goawk-old -f bm/bm.awk -- -n 10000000 -b inc,add_float
/path/to/goawk-new -f bm/bm.awk -- -n 10000000 -b inc,add_float
```

Omit `-b` to run all benchmarks. Use `--list` for names and `--help` for
options. Each benchmark has its own `bm_*` function and runs exactly `-n`
iterations. Selection order is preserved. Progress is printed before each
benchmark, followed by elapsed seconds, nanoseconds per iteration, and the
final result.

Timing uses the external `date +%s.%N` command (GNU date on Linux). Reported
times include loop overhead, function dispatch, and clock-command overhead;
they are wall-clock measurements, not isolated CPU instruction timings.
Use enough iterations for each benchmark to take at least a second, and repeat
runs to assess noise. The `empty` benchmark measures the loop baseline; it is
reported separately and is not automatically subtracted. Output and progress
reporting occur outside the timed loops.

To add an operation, add a `bm_*` function, its name and description in `BEGIN`,
and a dispatch branch in `run_benchmark`.
