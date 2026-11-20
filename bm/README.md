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

`unary_plus` and `unary_minus` apply ten nested unary `+` or `-` operators to
an int64 operand per iteration, following the `bit_not` benchmark.

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

### Compare commits

Run the awk driver with commit hashes in comparison order (usually oldest
first):

```sh
awk -f bm/compare_commits.awk -- -o bm/comparison.md ab32447 8850c11 7553277
```

By default it checks out each commit in `/home/xonix/proj/goawk-xonixx`,
builds it with `go build`, and runs `/home/xonix/proj/awk_lab/bm/bm.awk`
three times, with 20,000,000 iterations per benchmark on CPU core 17.
It retains the lowest `ns/op` **independently for each benchmark** across
those runs. Columns follow the supplied commit order, with a 7-character hash and a
short excerpt from its commit subject. The hash as supplied is included
in the column's HTML `title` attribute.

After each hash except the first, `-x% (-y%)` shows the overall duration
change versus the previous commit and versus the first commit, respectively.
The duration is the sum of each benchmark's minimum `seconds` across the runs,
including `empty` when present. These minima are independent of the `ns/op`
minima. Percentages use `(current / baseline - 1) * 100`, with two decimal
places: negative means faster, positive means slower. These percentages use
smaller, normal-weight text, colored green for faster and red for slower;
unchanged totals use normal text color. Nonpositive totals produce `n/a`
for the affected comparison.

```sh
awk -f bm/compare_commits.awk -- \
  --runs 5 --iterations 30000000 --cpu 17 \
  --benchmarks inc,add_float --output bm/comparison.md \
  ab32447 8850c11 7553277

# Override the repository and suite paths if needed:
awk -f bm/compare_commits.awk -- \
  --repo /path/to/goawk --suite /path/to/bm.awk \
  --output comparison.md HASH1 HASH2

# Compare current HEAD against uncommitted changes:
awk -f bm/compare_commits.awk -- --worktree --output bm/worktree.md

# Append a master baseline to either comparison mode:
awk -f bm/compare_commits.awk -- --master HASH1 HASH2
awk -f bm/compare_commits.awk -- --worktree --master --output bm/worktree.md
```

`--worktree` takes no commit hashes and compares the current `HEAD` with the
working files in `--repo`. The first column shows the HEAD hash; the second is
labeled `WORKTREE` and uses the same timing and speedup calculations. HEAD is
built in a temporary local clone, and the worktree is built in place, including
staged, unstaged, and untracked source files used by `go build`. No checkout or
stash is performed in the original repository, and its index and working files
are preserved. This also works with a clean worktree or a detached HEAD.

`--master` appends the tip of the local `master` branch as the last column,
built in a temporary clone. It uses a temporary copy of the suite with all
`BITWISE_BEGIN` through `BITWISE_END` sections removed, including the marker
lines. Keep bitwise names, dispatch branches, and functions inside those
sections. Explicit `--benchmarks` selections are restricted to benchmarks
available in the filtered suite for master. Excluded rows show `n/a`; if all
selected benchmarks are excluded, master has no timing runs and its column
contains only `n/a`. The original suite is preserved.

The master header shows its branch name, hash, and a single duration delta
versus the preceding column. Both totals sum each benchmark's minimum `seconds`
across runs over exactly the shared set of selected benchmarks, including
`empty` when present and excluding bitwise benchmarks. The delta uses
`(master_total / previous_total - 1) * 100`, with no comparison to the first
column. Header colors are inverted: negative is red, positive is green.
Nonpositive totals or no shared benchmarks produce `n/a`.

Its per-benchmark timings also use inverted colors versus the preceding column:
at least 5% lower is red, at least 3% higher is green, showing whether that
preceding build is slower or faster than master. Other timings use normal
text, and nonpositive timings are not highlighted. This flag works with
either commit hashes or `--worktree`; it uses local master without fetching.

Short options are `-r` (runs), `-n` (iterations), `-c` (CPU), `-b`
(benchmark selection), and `-o` (output). The default output is
`benchmark-report.md` in the current directory. Use `--help` for all options.
Requires Linux, a POSIX awk (tested with gawk and mawk), Git, Go, `taskset`,
and standard shell utilities. Choose a CPU allowed by your environment;
the driver checks affinity before building. Each comparison commit must support
the suite's syntax, including bitwise operators even when using `-b`;
the appended `--master` baseline uses the filtered suite described above.

Each cell is compared with the **previous column**: a decrease of at least
5% is bold green, and an increase of at least 3% is bold red. Other cells
use plain text. Percentage highlighting requires both values to be positive;
zero and negative baseline-subtracted timings are retained without highlighting.
The `empty` benchmark is omitted from the comparison table.
Color uses inline HTML (`span` with `style` and
`strong`); viewers that strip inline styles, including GitHub, may display
only the bold formatting.

When supplying commit hashes, the repository must have no staged or unstaged
changes to tracked files.
Untracked files are left in place, and checkout is never forced. Each build
uses a temporary binary and restores the original branch or detached HEAD
before benchmarking, including on build failure or catchable build interrupts.
An existing `goawk` binary is left untouched. Run only one driver at a time
per repository, and avoid editing or switching that repository during a run.
The report is written only after all commits and runs succeed; an existing
report is preserved if a build or benchmark fails. Temporary files are cleaned
up on normal completion and errors.

Test the driver using small temporary Git repositories and deterministic
build/benchmark substitutes:

```sh
python3 -m unittest discover -s bm -p 'test_*.py'
AWK=mawk python3 -m unittest discover -s bm -p 'test_*.py'
```
