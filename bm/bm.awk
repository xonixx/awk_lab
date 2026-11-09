# Run with any GoAWK build:
#   /path/to/goawk -f bm/bm.awk -- -n 10000000 -b inc,add_float
# Timing reads Linux /proc/uptime (0.01-second resolution).

BEGIN {
  bm()
}

function bm(   elapsed,result,started,name,bench,selected,count,selection,option,arg,available,iterations,
               empty_elapsed,empty_result) {
  iterations = 10000000 # 10 million
  available = "empty,inc,preinc,add_int,add_float,mul_float,div_float,assign"

  for (arg = 1; arg < ARGC; arg++) {
    option = ARGV[arg]
    if (option == "--")
      continue
    if (option == "-h" || option == "--help") {
      usage()
      exit
    }
    if (option == "--list") {
      list_benchmarks(available)
      exit
    }
    if (option == "-n" || option == "--iterations") {
      if (++arg >= ARGC)
        fail("missing value for " option)
      iterations = ARGV[arg]
    } else if (option == "-b" || option == "--benchmarks") {
      if (++arg >= ARGC)
        fail("missing value for " option)
      selection = ARGV[arg]
      if (selection == "")
        fail("benchmark list must not be empty")
    } else {
      fail("unknown option: " option)
    }
  }

  if (iterations !~ /^[0-9]+$/ || iterations + 0 < 1 || iterations + 0 > 9007199254740991)
    fail("iterations must be a positive integer at most 9007199254740991")
  iterations += 0
  if (selection == "")
    selection = available
  count = split(selection, selected, ",")
  # Validate the entire selection before running any benchmarks.
  for (bench = 1; bench <= count; bench++) {
    name = selected[bench]
    if (index("," available ",", "," name ",") == 0)
      fail("unknown benchmark: '" name "' (use --list)")
  }

  printf "Iterations per benchmark: %.0f\n", iterations
  printf "%-12s %12s %14s %16s\n", "benchmark", "seconds", "ns/op", "result"
  fflush()

  # Measure the common loop once, even when empty is not selected.
  started = now()
  empty_result = run_benchmark("empty", iterations)
  empty_elapsed = now() - started
  if (empty_elapsed <= 0)
    fail("clock did not advance for empty loop; increase iterations and rerun")

  for (bench = 1; bench <= count; bench++) {
    name = selected[bench]
    #        printf "Running %s\n", name
    fflush()
    if (name == "empty") {
      result = empty_result
      elapsed = empty_elapsed
    } else {
      started = now()
      result = run_benchmark(name, iterations)
      elapsed = now() - started
      if (elapsed <= 0)
        fail("clock did not advance; increase iterations and rerun")
    }
    printf "%-12s %12.2f %14.2f %16s\n", name, elapsed, \
      (elapsed - empty_elapsed) * 1e9 / (iterations * 10), result
    fflush()
  }
  # Do not read stdin or treat script options as input filenames.
  exit
}


function usage() {
  print "Usage: /path/to/goawk -f bm/bm.awk -- [options]"
  print "  -n, --iterations N     Iterations per benchmark (default: 10000000)"
  print "  -b, --benchmarks LIST  Comma-delimited names (default: all)"
  print "      --list             List benchmarks"
  print "  -h, --help             Show help"
  print "Timing uses Linux /proc/uptime (0.01-second resolution). Times include loop and clock-read overhead."
  print "ns/op subtracts the empty-loop time and divides by 10 operations per iteration."
}

function list_benchmarks(available,    names, n, i) {
  n = split(available, names, ",")
  for (i = 1; i <= n; i++)
    print names[i]
}

function fail(message) {
  print "bm.awk: " message > "/dev/stderr"
  exit 1
}

# /proc/uptime was about 81× faster per clock read on this machine
# compared to date command with +%s.%N
function now(    uptime, fields, status, read_status) {
  read_status = (getline uptime < "/proc/uptime")
  status = close("/proc/uptime")
  split(uptime, fields, " ")
  if (read_status != 1 || status != 0 || fields[1] !~ /^[0-9]+\.[0-9]+$/)
    fail("cannot read time from Linux /proc/uptime")
  return fields[1] + 0
}

# Dispatch once per benchmark, keeping function calls out of the hot loops.
function run_benchmark(name, n) {
  if (name == "empty") return bm_empty(n)
  if (name == "inc") return bm_inc(n)
  if (name == "preinc") return bm_preinc(n)
  if (name == "add_int") return bm_add_int(n)
  if (name == "add_float") return bm_add_float(n)
  if (name == "mul_float") return bm_mul_float(n)
  if (name == "div_float") return bm_div_float(n)
  if (name == "assign") return bm_assign(n)
}

function bm_empty(n,    i) {
  for (i = 0; i < n; i++) {}
  return i
}

function bm_inc(n,    i, a) {
  a = 0
  for (i = 0; i < n; i++) {
    a++;a++;a++;a++;a++;a++;a++;a++;a++;a++
  }
  return a
}

function bm_preinc(n,    i, a) {
  a = 0
  for (i = 0; i < n; i++) {
    ++a;++a;++a;++a;++a;++a;++a;++a;++a;++a
  }
  return a
}

function bm_add_int(n,    i, a) {
  a = 0
  for (i = 0; i < n; i++) {
    a += 1;a += 1;a += 1;a += 1;a += 1
    a += 1;a += 1;a += 1;a += 1;a += 1
  }
  return a
}

function bm_add_float(n,    i, b) {
  b = 0
  for (i = 0; i < n; i++) {
    b += 1.1;b += 1.1;b += 1.1;b += 1.1;b += 1.1
    b += 1.1;b += 1.1;b += 1.1;b += 1.1;b += 1.1
  }
  return b
}

function bm_mul_float(n,    i, b) {
  b = 1
  for (i = 0; i < n; i++) {
    b *= 1.00000001;b *= 1.00000001;b *= 1.00000001;b *= 1.00000001;b *= 1.00000001
    b *= 1.00000001;b *= 1.00000001;b *= 1.00000001;b *= 1.00000001;b *= 1.00000001
  }
  return b
}

function bm_div_float(n,    i, b) {
  b = 1
  for (i = 0; i < n; i++) {
    b /= 1.00000001;b /= 1.00000001;b /= 1.00000001;b /= 1.00000001;b /= 1.00000001
    b /= 1.00000001;b /= 1.00000001;b /= 1.00000001;b /= 1.00000001;b /= 1.00000001
  }
  return b
}

function bm_assign(n,    i, a, b) {
  b = 42
  for (i = 0; i < n; i++) {
    a = b;a = b;a = b;a = b;a = b;a = b;a = b;a = b;a = b;a = b
  }
  return a
}
