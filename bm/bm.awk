# Run with a goawk-xonixx build supporting bitwise operators:
#   /path/to/goawk -f bm/bm.awk -- -n 10000000 -b inc,add_float
# Timing reads Linux /proc/uptime (0.01-second resolution).

BEGIN {
  Iterations = 10000000 # 10 million
  Available = "empty,inc,preinc,add_int,add_float,add_float_expr,sub_float,sub_float_expr"
  Available = Available ",mul_float,mul_float_expr,div_float,div_float_expr,mod_float_expr,assign"
  Available = Available ",unary_plus,unary_minus"
  Available = Available ",bit_and,bit_or,bit_xor,bit_not,bit_lshift,bit_rshift,bit_urshift"
  Available = Available ",bit_and_assign,bit_or_assign,bit_xor_assign,bit_lshift_assign,bit_rshift_assign,bit_urshift_assign"
  bm()
}

function bm(   elapsed,result,started,name,bench,selected,count,selection,option,arg,empty_elapsed,empty_result) {
  for (arg = 1; arg < ARGC; arg++) {
    option = ARGV[arg]
    if (option == "--")
      continue
    if (option == "-h" || option == "--help") {
      usage()
      exit
    }
    if (option == "--list") {
      list_benchmarks(Available)
      exit
    }
    if (option == "-n" || option == "--iterations") {
      if (++arg >= ARGC)
        fail("missing value for " option)
      Iterations = ARGV[arg]
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

  if (Iterations !~ /^[0-9]+$/ || Iterations + 0 < 1 || Iterations + 0 > 9007199254740991)
    fail("iterations must be a positive integer at most 9007199254740991")
  Iterations += 0
  if (selection == "")
    selection = Available
  count = split(selection, selected, ",")
  # Validate the entire selection before running any benchmarks.
  for (bench = 1; bench <= count; bench++) {
    name = selected[bench]
    if (index("," Available ",", "," name ",") == 0)
      fail("unknown benchmark: '" name "' (use --list)")
  }

  printf "Iterations per benchmark: %.0f\n", Iterations
  printf "%-20s %12s %14s %20s\n", "benchmark", "seconds", "ns/op", "result"
  fflush()

  # Measure the common loop once, even when empty is not selected.
  started = now()
  empty_result = run_benchmark("empty", Iterations)
  empty_elapsed = now() - started
  if (empty_elapsed <= 0)
    fail("clock did not advance for empty loop; increase iterations and rerun")

  for (bench = 1; bench <= count; bench++) {
    name = selected[bench]
#    printf "Running %s\n", name
#    fflush()
    if (name == "empty") {
      result = empty_result
      elapsed = empty_elapsed
    } else {
      started = now()
      result = run_benchmark(name, Iterations)
      elapsed = now() - started
      if (elapsed <= 0)
        fail("clock did not advance; increase iterations and rerun")
    }
    printf "%-20s %12.2f %14.2f %20s\n", name, elapsed, \
      (elapsed - empty_elapsed) * 1e9 / (Iterations * 10), result
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
  if (name == "add_float_expr") return bm_add_float_expr(n)
  if (name == "sub_float") return bm_sub_float(n)
  if (name == "sub_float_expr") return bm_sub_float_expr(n)
  if (name == "mul_float") return bm_mul_float(n)
  if (name == "mul_float_expr") return bm_mul_float_expr(n)
  if (name == "div_float") return bm_div_float(n)
  if (name == "div_float_expr") return bm_div_float_expr(n)
  if (name == "mod_float_expr") return bm_mod_float_expr(n)
  if (name == "assign") return bm_assign(n)
  if (name == "unary_plus") return bm_unary_plus(n)
  if (name == "unary_minus") return bm_unary_minus(n)
  if (name == "bit_and") return bm_bit_and(n)
  if (name == "bit_or") return bm_bit_or(n)
  if (name == "bit_xor") return bm_bit_xor(n)
  if (name == "bit_not") return bm_bit_not(n)
  if (name == "bit_lshift") return bm_bit_lshift(n)
  if (name == "bit_rshift") return bm_bit_rshift(n)
  if (name == "bit_urshift") return bm_bit_urshift(n)
  if (name == "bit_and_assign") return bm_bit_and_assign(n)
  if (name == "bit_or_assign") return bm_bit_or_assign(n)
  if (name == "bit_xor_assign") return bm_bit_xor_assign(n)
  if (name == "bit_lshift_assign") return bm_bit_lshift_assign(n)
  if (name == "bit_rshift_assign") return bm_bit_rshift_assign(n)
  if (name == "bit_urshift_assign") return bm_bit_urshift_assign(n)
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

function bm_add_float_expr(n,    i, b) {
  b = 0
  for (i = 0; i < n; i++) {
    b += 1.1 + 1.1 + 1.1 + 1.1 + 1.1 + 1.1 + 1.1 + 1.1 + 1.1 + 1.1
  }
  return b
}

function bm_sub_float(n,    i, b) {
  b = 0
  for (i = 0; i < n; i++) {
    b -= 1.1;b -= 1.1;b -= 1.1;b -= 1.1;b -= 1.1
    b -= 1.1;b -= 1.1;b -= 1.1;b -= 1.1;b -= 1.1
  }
  return b
}

function bm_sub_float_expr(n,    i, b) {
  b = 0
  for (i = 0; i < n; i++) {
    b = b - 1.1 - 1.1 - 1.1 - 1.1 - 1.1 - 1.1 - 1.1 - 1.1 - 1.1 - 1.1
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

function bm_mul_float_expr(n,    i, b) {
  b = 1
  for (i = 0; i < n; i++) {
    b = b * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001 * 1.00000001
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

function bm_div_float_expr(n,    i, b) {
  b = 1
  for (i = 0; i < n; i++) {
    b = b / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001 / 1.00000001
  }
  return b
}

function bm_mod_float_expr(n,    i, b) {
  b = 42.5
  for (i = 0; i < n; i++) {
    b = b % 1.1 % 1.1 % 1.1 % 1.1 % 1.1 % 1.1 % 1.1 % 1.1 % 1.1 % 1.1
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

# Separate unary signs to avoid the ++ and -- operators.
function bm_unary_plus(n,    i, a) {
  a = 42
  for (i = 0; i < n; i++) {
    a = + + + + + + + + + +a
  }
  return a
}

function bm_unary_minus(n,    i, a) {
  a = 42
  for (i = 0; i < n; i++) {
    a = - - - - - - - - - -a
  }
  return a
}

# Exercise the fork's int64 operators, including bits above float64's exact range.
function bm_bit_and(n,    i, a, b) {
  a = 0x123456789abcdef0
  b = 0x0f0f0f0f0f0f0f0f
  for (i = 0; i < n; i++) {
    a = a & b & b & b & b & b & b & b & b & b & b
  }
  return a
}

function bm_bit_or(n,    i, a, b) {
  a = 0x123456789abcdef0
  b = 0x0f0f0f0f0f0f0f0f
  for (i = 0; i < n; i++) {
    a = a | b | b | b | b | b | b | b | b | b | b
  }
  return a
}

function bm_bit_xor(n,    i, a, b) {
  a = 0x123456789abcdef0
  b = 0x0f0f0f0f0f0f0f0f
  for (i = 0; i < n; i++) {
    a = a ^ b ^ b ^ b ^ b ^ b ^ b ^ b ^ b ^ b ^ b
  }
  return a
}

function bm_bit_not(n,    i, a) {
  a = 0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a = ~~~~~~~~~~a
  }
  return a
}

# Repeated shifts settle at 0 (left/unsigned right) or -1 (signed right).
# The VM still executes all ten int64 operations on every iteration.
function bm_bit_lshift(n,    i, a) {
  a = 0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a = a << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1 << 1
  }
  return a
}

function bm_bit_rshift(n,    i, a) {
  a = -0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a = a >> 1 >> 1 >> 1 >> 1 >> 1 >> 1 >> 1 >> 1 >> 1 >> 1
  }
  return a
}

function bm_bit_urshift(n,    i, a) {
  a = -0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a = a >>> 1 >>> 1 >>> 1 >>> 1 >>> 1 >>> 1 >>> 1 >>> 1 >>> 1 >>> 1
  }
  return a
}

function bm_bit_and_assign(n,    i, a, b) {
  a = 0x123456789abcdef0
  b = 0x0f0f0f0f0f0f0f0f
  for (i = 0; i < n; i++) {
    a &= b;a &= b;a &= b;a &= b;a &= b
    a &= b;a &= b;a &= b;a &= b;a &= b
  }
  return a
}

function bm_bit_or_assign(n,    i, a, b) {
  a = 0x123456789abcdef0
  b = 0x0f0f0f0f0f0f0f0f
  for (i = 0; i < n; i++) {
    a |= b;a |= b;a |= b;a |= b;a |= b
    a |= b;a |= b;a |= b;a |= b;a |= b
  }
  return a
}

function bm_bit_xor_assign(n,    i, a, b) {
  a = 0x123456789abcdef0
  b = 0x0f0f0f0f0f0f0f0f
  for (i = 0; i < n; i++) {
    a ^= b;a ^= b;a ^= b;a ^= b;a ^= b
    a ^= b;a ^= b;a ^= b;a ^= b;a ^= b
  }
  return a
}

function bm_bit_lshift_assign(n,    i, a) {
  a = 0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a <<= 1;a <<= 1;a <<= 1;a <<= 1;a <<= 1
    a <<= 1;a <<= 1;a <<= 1;a <<= 1;a <<= 1
  }
  return a
}

function bm_bit_rshift_assign(n,    i, a) {
  a = -0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a >>= 1;a >>= 1;a >>= 1;a >>= 1;a >>= 1
    a >>= 1;a >>= 1;a >>= 1;a >>= 1;a >>= 1
  }
  return a
}

function bm_bit_urshift_assign(n,    i, a) {
  a = -0x123456789abcdef0
  for (i = 0; i < n; i++) {
    a >>>= 1;a >>>= 1;a >>>= 1;a >>>= 1;a >>>= 1
    a >>>= 1;a >>>= 1;a >>>= 1;a >>>= 1;a >>>= 1
  }
  return a
}
