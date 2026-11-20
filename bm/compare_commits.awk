#!/usr/bin/awk -f
# Compare GoAWK commits using minimum ns/op and total best elapsed seconds.
# Usage: awk -f bm/compare_commits.awk -- [options] HASH [HASH ...]
#    or: awk -f bm/compare_commits.awk -- [options] --worktree

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
  if (!Worktree && capture(Git "status --porcelain --untracked-files=no", "check repository status") != "")
    fail("repository has staged or unstaged tracked changes; commit or stash them first")

  if (Worktree) {
    CommitCount = 2
    Commit[1] = OriginalHead
    Commit[2] = "WORKTREE"
  }
  if (Master) {
    MasterColumn = ++CommitCount
    Commit[MasterColumn] = capture(Git "rev-parse --verify " quote("refs/heads/master^{commit}"), "resolve master branch")
  }
  for (c = 1; c <= CommitCount; c++) {
    if (Worktree && c == 2)
      Subject[c] = "Current worktree"
    else
      Subject[c] = capture(Git "show -s --format=%s " quote(Commit[c]), "read commit message")
  }
  GoVersion = capture("LC_ALL=C go version", "read Go version")
  Temp = capture("mktemp -d \"${TMPDIR:-/tmp}/goawk-compare.XXXXXXXX\"", "create temporary directory")
  if (Temp == "")
    fail("mktemp returned no directory")
  Temp = absolute(Temp)
  if (Master) {
    MasterSuite = Temp "/bm-master.awk"
    if (system("awk '/BITWISE_BEGIN/,/BITWISE_END/ {next} 1' " quote(Suite) " > " quote(MasterSuite)) != 0)
      fail("cannot prepare benchmark suite for master")
  }

  for (c = 1; c <= CommitCount; c++) {
    log_message("[" c "/" CommitCount "] Building " Commit[c] ": " Subject[c])
    build(c)
    if (c == MasterColumn) {
      master_benchmarks()
      if (!MasterBenchCount) {
        log_message("  No selected benchmarks supported by master; its column will contain n/a")
        continue
      }
    }
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
  print "   or: awk -f bm/compare_commits.awk -- [options] --worktree"
  print "Compare commits in the order supplied (usually oldest first)."
  print "      --worktree        Compare current HEAD with working files (no hashes)"
  print "      --master          Append local master baseline without bitwise benchmarks"
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
    if (!positional && option == "--worktree") {
      Worktree = 1
      continue
    }
    if (!positional && option == "--master") {
      Master = 1
      continue
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
  if (Worktree && CommitCount)
    fail("--worktree cannot be combined with commit hashes")
  if (!Worktree && !CommitCount)
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
  return value ~ /^[0-9]+$/ && +value >= minimum && +value <= 9007199254740991
}

function build(c,    restore, cmd) {
  if (Worktree || c == MasterColumn) {
    build_isolated(c)
    return
  }
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

function build_isolated(c,    dir, cmd) {
  dir = Worktree && c == 2 ? Repo : Temp "/checkout-" c
  cmd = "set -eu\n"
  if (dir != Repo) {
    # Borrow Git objects for a temporary checkout without touching the
    # original branch, index, or working files, even when the build fails.
    cmd = cmd "git clone --quiet --shared --no-checkout -- " quote(Repo) " " quote(dir) "\n" \
      "git -C " quote(dir) " checkout --quiet --detach " quote(Commit[c]) "\n"
  }
  cmd = cmd "cd " quote(dir) "\ngo build -o " quote(Temp "/goawk") " .\n"
  if (system(cmd) != 0)
    fail("build failed for " Commit[c] " (see diagnostics above)")
}

function master_benchmarks(    cmd, listed, count, i, b, name, supported) {
  cmd = "cd " quote(Repo) " && LC_ALL=C " quote(Temp "/goawk") " -f " quote(MasterSuite) " -- --list"
  count = split(capture(cmd, "list master benchmarks"), listed, "\n")
  for (i = 1; i <= count; i++) {
    name = listed[i]
    if (name !~ /^[a-zA-Z_][a-zA-Z_0-9]*$/ || name in supported)
      fail("unexpected master benchmark name: " name)
    supported[name] = 1
  }
  for (b = 1; b <= BenchCount; b++) {
    name = Names[b]
    if (name in supported) {
      MasterExpected[name] = 1
      MasterSelection = MasterSelection (MasterBenchCount++ ? "," : "") name
    }
  }
}

function benchmark(c, run,    cmd, file, line, fields, count, name, value, seconds, key, status, header, rows, suite, selection) {
  file = Temp "/run.txt"
  suite = c == MasterColumn ? MasterSuite : Suite
  selection = c == MasterColumn ? MasterSelection : Selection
  cmd = "cd " quote(Repo) " && LC_ALL=C taskset -c " quote(CPU) " " quote(Temp "/goawk") \
    " -f " quote(suite) " -- -n " quote(Iterations)
  if (selection != "")
    cmd = cmd " -b " quote(selection)
  if (system(cmd " > " quote(file)) != 0) {
    system("cat -- " quote(file) " >&2")
    fail("benchmark failed for " Commit[c] ", run " run)
  }
  delete Seen
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
    value = +fields[3]
    seconds = +fields[2]
    if (name in Seen)
      fail("duplicate benchmark: " name)
    Seen[name] = 1
    rows++
    if (c == 1 && run == 1) {
      Names[++BenchCount] = name
      Known[name] = 1
    } else if ((c == MasterColumn && !(name in MasterExpected)) || !(name in Known)) {
      fail("benchmark set changed: unexpected " name " in " Commit[c] ", run " run)
    }
    key = c SUBSEP name
    if (!(key in Best) || value < Best[key])
      Best[key] = value
    if (!(key in BestSeconds) || seconds < BestSeconds[key])
      BestSeconds[key] = seconds
  }
  if (close(file) != 0 || status < 0)
    fail("cannot read benchmark output")
  if (!rows || rows != (c == MasterColumn ? MasterBenchCount : BenchCount))
    fail("missing benchmark rows in " Commit[c] ", run " run)
}

function number(value) {
  return value ~ /^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)([eE][+-]?[0-9]+)?$/
}

function report(file,    c, b, name, value, previous, cell, subject, row, totals) {
  for (c = 1; c <= CommitCount; c++)
    if (c != MasterColumn)
      for (b = 1; b <= BenchCount; b++)
        totals[c] += BestSeconds[c, Names[b]]
  print "# GoAWK benchmark comparison" > file
  print "" > file
  print "Values are **ns/op**, taking the minimum for each benchmark across **" Runs " runs** per commit." > file
  print "Iterations per benchmark: **" Iterations "**. CPU core: **" CPU "** (`taskset -c " CPU "`)." > file
  print "Go: " html(GoVersion) ". Suite: <code>" html(Suite) "</code>." > file
  print "" > file
  print "Header percentages show the change in total duration versus the previous commit (first commit in parentheses); negative (green) means faster, positive (red) means slower." > file
  print "Total duration sums the minimum **seconds** for each benchmark across runs, including `empty` when present. Percentages require positive totals." > file
  print "Commits appear in CLI order. Each value is compared to the column immediately to its left:" > file
  print "**green** = at least 5% faster; **red** = at least 3% slower. Other values use normal text." > file
  if (Master)
    print "The final **master** column excludes bitwise benchmarks (shown as n/a), has no aggregate percentages, and reverses the colors: lower is red, higher is green, using the same thresholds." > file
  print "Zero/negative values are retained as timing noise; percentage highlighting requires two positive values." > file
  print "" > file
  row = "| Benchmark"
  for (c = 1; c <= CommitCount; c++) {
    subject = Subject[c]
    if (length(subject) > 40) subject = substr(subject, 1, 37) "..."
    row = row " | <code title=\"" Commit[c] "\">" (c == MasterColumn ? "master " : "") (Worktree && c == 2 ? Commit[c] : substr(Commit[c], 1, 7)) "</code>"
    if (c > 1 && c != MasterColumn)
      row = row " <small style=\"font-weight: normal\">" duration_change(totals[c], totals[c - 1]) " " duration_change(totals[c], totals[1], 1) "</small>"
    row = row "<br><small>" html(subject) "</small>"
  }
  print row " |" > file
  row = "| :---"
  for (c = 1; c <= CommitCount; c++) row = row " | ---:"
  print row " |" > file
  for (b = 1; b <= BenchCount; b++) {
    name = Names[b]
    if (name == "empty")
      continue
    row = "| `" name "`"
    for (c = 1; c <= CommitCount; c++) {
      if (!((c SUBSEP name) in Best)) {
        row = row " | n/a"
        continue
      }
      value = Best[c, name]
      cell = sprintf("%.2f", value)
      if (c > 1) {
        previous = Best[c - 1, name]
        if (previous > 0 && value > 0) {
          if (value * 100 <= previous * 95)
            cell = "<span style=\"color: " (c == MasterColumn ? "red" : "green") "\"><strong>" cell "</strong></span>"
          else if (value * 100 >= previous * 103)
            cell = "<span style=\"color: " (c == MasterColumn ? "green" : "red") "\"><strong>" cell "</strong></span>"
        }
      }
      row = row " | " cell
    }
    print row " |" > file
  }
  if (close(file) != 0)
    fail("cannot finish report")
}

function duration_change(current, baseline, parentheses,    value) {
  value = current <= 0 || baseline <= 0 ? "n/a" : sprintf("%+.2f%%", (current / baseline - 1) * 100)
  if (parentheses)
    value = "(" value ")"
  if (current <= 0 || baseline <= 0 || current == baseline)
    return value
  return "<span style=\"color: " (current < baseline ? "green" : "red") "\">" value "</span>"
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
