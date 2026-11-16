#!/usr/bin/awk -f
# Compare GoAWK commits using the minimum ns/op for each benchmark.
# Usage: awk -f bm/compare_commits.awk -- [options] HASH [HASH ...]

BEGIN {
  CONVFMT = "%.17g"
  Repo = "/home/xonix/proj/goawk-xonixx"
  Suite = "/home/xonix/proj/awk_lab/bm/bm.awk"
  Output = "benchmark-report.md"
  Runs = 3
  Iterations = 20000000
  CPU = 17
  parse_cli()
  Cwd = capture("pwd -P", "read current directory")
  Repo = absolute(Repo)
  Suite = absolute(Suite)
  Output = absolute(Output)
  Git = "LC_ALL=C git -C " quote(Repo) " "

  if (system("command -v git >/dev/null && command -v go >/dev/null && command -v taskset >/dev/null") != 0)
    fail("git, go, and taskset must be on PATH")
  if (system("test -r " quote(Suite)) != 0)
    fail("cannot read benchmark suite: " Suite)
  if (system("test ! -d " quote(Output)) != 0)
    fail("output must be a file: " Output)
  if (system("LC_ALL=C taskset -c " quote(CPU) " true") != 0)
    fail("cannot bind to CPU " CPU " (check your allowed CPU set)")
  OriginalHead = capture(Git "rev-parse --verify HEAD", "read repository HEAD")
  OriginalBranch = capture(Git "symbolic-ref -q --short HEAD || :", "read original branch")
  if (capture(Git "status --porcelain --untracked-files=no", "check repository status") != "")
    fail("repository has staged or unstaged tracked changes; commit or stash them first")

  for (c = 1; c <= CommitCount; c++)
    Subject[c] = capture(Git "show -s --format=%s " quote(Commit[c]), "read commit message")
  GoVersion = capture("LC_ALL=C go version", "read Go version")
  Temp = capture("mktemp -d \"${TMPDIR:-/tmp}/goawk-compare.XXXXXXXX\"", "create temporary directory")
  if (Temp == "")
    fail("mktemp returned no directory")
  Temp = absolute(Temp)

  for (c = 1; c <= CommitCount; c++) {
    log_message("[" c "/" CommitCount "] Building " Commit[c] ": " Subject[c])
    build(c)
    for (r = 1; r <= Runs; r++) {
      log_message("  Run " r "/" Runs " on CPU " CPU)
      benchmark(c, r)
    }
  }
  report(Temp "/report.md")
  if (system("mv -f -- " quote(Temp "/report.md") " " quote(Output)) != 0)
    fail("cannot write report: " Output)
  log_message("Report written to " Output)
  exit
}

END {
  if (Temp != "")
    system("rm -rf -- " quote(Temp))
}

function usage() {
  print "Usage: awk -f bm/compare_commits.awk -- [options] HASH [HASH ...]"
  print "Compare commits in the order supplied (usually oldest first)."
  print "  -r, --runs N          Suite runs per commit (default: 3)"
  print "  -n, --iterations N    Iterations per benchmark (default: 20000000)"
  print "  -c, --cpu N           CPU core for taskset (default: 17)"
  print "  -o, --output FILE     Markdown report (default: benchmark-report.md)"
  print "  -b, --benchmarks LIST Comma-separated benchmark names (default: all)"
  print "      --repo DIR        GoAWK repository (default: /home/xonix/proj/goawk-xonixx)"
  print "      --suite FILE      Suite (default: /home/xonix/proj/awk_lab/bm/bm.awk)"
  print "  -h, --help            Show help"
}

function parse_cli(    i, option, value, positional) {
  for (i = 1; i < ARGC; i++) {
    option = ARGV[i]
    if (!positional && option == "--") {
      positional = 1
      continue
    }
    if (!positional && (option == "-h" || option == "--help")) {
      usage()
      exit
    }
    if (!positional && option ~ /^-/) {
      if (option != "-r" && option != "--runs" && option != "-n" && option != "--iterations" &&
          option != "-c" && option != "--cpu" && option != "-o" && option != "--output" &&
          option != "-b" && option != "--benchmarks" && option != "--repo" && option != "--suite")
        fail("unknown option: " option)
      if (++i >= ARGC || ARGV[i] == "")
        fail("missing value for " option)
      value = ARGV[i]
      if (option == "-r" || option == "--runs") Runs = value
      else if (option == "-n" || option == "--iterations") Iterations = value
      else if (option == "-c" || option == "--cpu") CPU = value
      else if (option == "-o" || option == "--output") Output = value
      else if (option == "-b" || option == "--benchmarks") Selection = value
      else if (option == "--repo") Repo = value
      else if (option == "--suite") Suite = value
    } else {
      if (option !~ /^[0-9a-fA-F]+$/ || length(option) > 64)
        fail("expected a commit hash, got: " option)
      Commit[++CommitCount] = option
    }
  }
  if (!CommitCount)
    fail("provide at least one commit hash (use --help for options)")
  if (!integer(Runs, 1)) fail("runs must be a positive integer at most 9007199254740991")
  if (!integer(Iterations, 1)) fail("iterations must be a positive integer at most 9007199254740991")
  if (!integer(CPU, 0)) fail("cpu must be a nonnegative integer at most 9007199254740991")
  # Keep counters numeric, and normalize leading zeroes in shell arguments.
  Runs += 0
  Iterations += 0
  CPU += 0
}

function integer(value, minimum) {
  return value ~ /^[0-9]+$/ && value + 0 >= minimum && value + 0 <= 9007199254740991
}

function build(c,    restore, cmd) {
  restore = OriginalBranch != "" ? OriginalBranch : OriginalHead
  # The shell owns the checkout/build/restore sequence, so its EXIT trap also
  # restores on a build error or a catchable interrupt. Never force checkout.
  cmd = "set -eu\ncd " quote(Repo) "\n" \
    "restore() {\n" \
    "  status=$?\n" \
    "  trap - 0 HUP INT TERM\n" \
    "  if ! git checkout --quiet " quote(restore) "; then\n" \
    "    echo 'compare_commits.awk: could not restore original checkout' >&2\n" \
    "    exit 1\n" \
    "  fi\n" \
    "  exit \"$status\"\n" \
    "}\n" \
    "trap restore 0\n" \
    "trap 'exit 129' HUP\ntrap 'exit 130' INT\ntrap 'exit 143' TERM\n" \
    "git checkout --quiet --detach " quote(Commit[c]) "\n" \
    "go build -o " quote(Temp "/goawk") " .\n"
  if (system(cmd) != 0)
    fail("checkout/build failed for " Commit[c] " (see diagnostics above)")
}

function benchmark(c, run,    cmd, file, line, fields, count, name, value, key, status, header, rows) {
  file = Temp "/run.txt"
  cmd = "cd " quote(Repo) " && LC_ALL=C taskset -c " quote(CPU) " " quote(Temp "/goawk") \
    " -f " quote(Suite) " -- -n " quote(Iterations)
  if (Selection != "")
    cmd = cmd " -b " quote(Selection)
  if (system(cmd " > " quote(file)) != 0) {
    system("cat -- " quote(file) " >&2")
    fail("benchmark failed for " Commit[c] ", run " run)
  }
  for (key in Seen) delete Seen[key]
  while ((status = (getline line < file)) > 0) {
    if (line ~ /^[[:space:]]*$/ || line ~ /^Iterations per benchmark:/)
      continue
    count = split(line, fields, " ")
    if (count == 4 && fields[1] == "benchmark" && fields[2] == "seconds" && fields[3] == "ns/op" && fields[4] == "result") {
      header = 1
      continue
    }
    if (!header || count != 4 || fields[1] !~ /^[a-zA-Z_][a-zA-Z_0-9]*$/ || !number(fields[2]) || !number(fields[3]))
      fail("unexpected benchmark output: " line)
    name = fields[1]
    value = fields[3] + 0
    if (name in Seen)
      fail("duplicate benchmark: " name)
    Seen[name] = 1
    rows++
    if (c == 1 && run == 1) {
      Names[++BenchCount] = name
      Known[name] = 1
    } else if (!(name in Known)) {
      fail("benchmark set changed: unexpected " name " in " Commit[c] ", run " run)
    }
    key = c SUBSEP name
    if (!(key in Best) || value < Best[key])
      Best[key] = value
  }
  if (close(file) != 0 || status < 0)
    fail("cannot read benchmark output")
  if (!rows || rows != BenchCount)
    fail("missing benchmark rows in " Commit[c] ", run " run)
}

function number(value) {
  return value ~ /^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$/
}

function report(file,    c, b, name, value, previous, cell, subject, row) {
  print "# GoAWK benchmark comparison" > file
  print "" > file
  print "Values are **ns/op**, taking the minimum for each benchmark across **" Runs " runs** per commit." > file
  print "Iterations per benchmark: **" Iterations "**. CPU core: **" CPU "** (`taskset -c " CPU "`)." > file
  print "Go: " html(GoVersion) ". Suite: <code>" html(Suite) "</code>." > file
  print "" > file
  print "Commits appear in CLI order. Each value is compared to the column immediately to its left:" > file
  print "**green** = at least 5% faster; **red** = at least 3% slower. Other values use normal text." > file
  print "Zero/negative values are retained as timing noise; percentage highlighting requires two positive values." > file
  print "" > file
  row = "| Benchmark"
  for (c = 1; c <= CommitCount; c++) {
    subject = Subject[c]
    if (length(subject) > 60) subject = substr(subject, 1, 57) "..."
    row = row " | <code title=\"" Commit[c] "\">" substr(Commit[c], 1, 7) "</code><br><small>" html(subject) "</small>"
  }
  print row " |" > file
  row = "| :---"
  for (c = 1; c <= CommitCount; c++) row = row " | ---:"
  print row " |" > file
  for (b = 1; b <= BenchCount; b++) {
    name = Names[b]
    row = "| `" name "`"
    for (c = 1; c <= CommitCount; c++) {
      value = Best[c, name]
      cell = sprintf("%.2f", value)
      if (c > 1) {
        previous = Best[c - 1, name]
        if (previous > 0 && value > 0) {
          if (value * 100 <= previous * 95)
            cell = "<span style=\"color: green\"><strong>" cell "</strong></span>"
          else if (value * 100 >= previous * 103)
            cell = "<span style=\"color: red\"><strong>" cell "</strong></span>"
        }
      }
      row = row " | " cell
    }
    print row " |" > file
  }
  if (close(file) != 0)
    fail("cannot finish report")
}

function absolute(path) {
  return substr(path, 1, 1) == "/" ? path : Cwd "/" path
}

function quote(value,    result, i, ch) {
  result = "'"
  for (i = 1; i <= length(value); i++) {
    ch = substr(value, i, 1)
    result = result (ch == "'" ? "'\"'\"'" : ch)
  }
  return result "'"
}

function html(value,    result, i, ch) {
  for (i = 1; i <= length(value); i++) {
    ch = substr(value, i, 1)
    if (ch == "&") ch = "&amp;"
    else if (ch == "<") ch = "&lt;"
    else if (ch == ">") ch = "&gt;"
    else if (ch == "\"") ch = "&quot;"
    else if (ch == "|") ch = "&#124;"
    else if (ch == "`") ch = "&#96;"
    else if (ch == "*") ch = "&#42;"
    else if (ch == "_") ch = "&#95;"
    else if (ch == "\\") ch = "&#92;"
    else if (ch == "[") ch = "&#91;"
    else if (ch == "]") ch = "&#93;"
    result = result ch
  }
  return result
}

function capture(cmd, context,    line, result, status, count) {
  while ((status = (cmd | getline line)) > 0)
    result = result (count++ ? "\n" : "") line
  if (close(cmd) != 0 || status < 0)
    fail("could not " context)
  return result
}

function log_message(message) {
  print message > "/dev/stderr"
  fflush("/dev/stderr")
}

function fail(message) {
  log_message("compare_commits.awk: " message)
  exit 1
}
