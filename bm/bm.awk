# Run with any GoAWK build:
#   /path/to/goawk -f bm/bm.awk -- -n 10000000 -b inc,add_float
# Timing requires a date command supporting +%s.%N (for example GNU date).

BEGIN {
    iterations = 10000000
    available = "empty,inc,preinc,add_int,add_float,mul_float,div_float,assign,concat"
    descriptions["empty"] = "empty loop (baseline)"
    descriptions["inc"] = "a++"
    descriptions["preinc"] = "++a"
    descriptions["add_int"] = "a += 1"
    descriptions["add_float"] = "b += 1.1"
    descriptions["mul_float"] = "b *= 1.00000001"
    descriptions["div_float"] = "b /= 1.00000001"
    descriptions["assign"] = "a = b"
    descriptions["concat"] = "a = b c (fixed strings)"

    for (arg = 1; arg < ARGC; arg++) {
        option = ARGV[arg]
        if (option == "--")
            continue
        if (option == "-h" || option == "--help") {
            usage()
            exit
        }
        if (option == "--list") {
            list_benchmarks()
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
        if (!(name in descriptions))
            fail("unknown benchmark: '" name "' (use --list)")
    }

    printf "Iterations per benchmark: %.0f\n", iterations
    printf "%-12s %12s %14s %s\n", "benchmark", "seconds", "ns/op", "result"
    fflush()
    for (bench = 1; bench <= count; bench++) {
        name = selected[bench]
        printf "Running %s: %s\n", name, descriptions[name]
        fflush()
        started = now()
        result = run_benchmark(name, iterations)
        elapsed = now() - started
        if (elapsed <= 0)
            fail("clock did not advance; increase iterations and rerun")
        printf "%-12s %12.6f %14.2f %s\n", name, elapsed, elapsed * 1e9 / iterations, result
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
    print "Timing requires date +%s.%N. Times include loop and clock-command overhead."
}

function list_benchmarks(    names, n, i) {
    n = split(available, names, ",")
    for (i = 1; i <= n; i++)
        printf "%-12s %s\n", names[i], descriptions[names[i]]
}

function fail(message) {
    print "bm.awk: " message > "/dev/stderr"
    exit 1
}

function now(    command, timestamp, status, read_status) {
    command = "date +%s.%N"
    read_status = (command | getline timestamp)
    status = close(command)
    if (read_status != 1 || status != 0 || timestamp !~ /^[0-9]+\.[0-9]+$/)
        fail("cannot read high-resolution time: date must support +%s.%N")
    return timestamp + 0
}

# Dispatch once per benchmark, keeping function calls out of the hot loops.
function run_benchmark(name, n) {
    if (name == "empty")     return bm_empty(n)
    if (name == "inc")       return bm_inc(n)
    if (name == "preinc")    return bm_preinc(n)
    if (name == "add_int")   return bm_add_int(n)
    if (name == "add_float") return bm_add_float(n)
    if (name == "mul_float") return bm_mul_float(n)
    if (name == "div_float") return bm_div_float(n)
    if (name == "assign")    return bm_assign(n)
    if (name == "concat")    return bm_concat(n)
}

function bm_empty(n,    i) {
    for (i = 0; i < n; i++) {}
    return i
}

function bm_inc(n,    i, a) {
    a = 0
    for (i = 0; i < n; i++) a++
    return a
}

function bm_preinc(n,    i, a) {
    a = 0
    for (i = 0; i < n; i++) ++a
    return a
}

function bm_add_int(n,    i, a) {
    a = 0
    for (i = 0; i < n; i++) a += 1
    return a
}

function bm_add_float(n,    i, b) {
    b = 0
    for (i = 0; i < n; i++) b += 1.1
    return b
}

function bm_mul_float(n,    i, b) {
    b = 1
    for (i = 0; i < n; i++) b *= 1.00000001
    return b
}

function bm_div_float(n,    i, b) {
    b = 1
    for (i = 0; i < n; i++) b /= 1.00000001
    return b
}

function bm_assign(n,    i, a, b) {
    b = 42
    for (i = 0; i < n; i++) a = b
    return a
}

function bm_concat(n,    i, a, b, c) {
    b = "hello"
    c = "world"
    for (i = 0; i < n; i++) a = b c
    return a
}
