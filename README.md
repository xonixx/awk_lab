## AWK Lab

[![Run tests](https://github.com/xonixx/awk_lab/actions/workflows/run-tests.yml/badge.svg)](https://github.com/xonixx/awk_lab/actions/workflows/run-tests.yml)

My experiments with [AWK](https://maximullaris.com/awk_tech_notes.html).

- [Experiments with JSON](README_json.md)
- [nat_sort.awk](nat_sort.awk) - Natural sorting
- CLI
  - [parse_cli_0_lib.awk](parse_cli_0_lib.awk) - basic utility to parse CLI `"  aaa 'bbb cc'  'd\'ee' "` -> `["aaa", "bbb cc", "d'ee"]`
    - Not shell-compatible, this is why we came up with `parse_cli_lib_1.awk` 
  - [parse_cli_1_lib.awk](parse_cli_1_lib.awk) - basic utility to parse CLI `"  aaa 'bbb cc'  $'d\'ee' "` -> `["aaa", "bbb cc", "d'ee"]`
  - [reparse_cli.awk](reparse_cli.awk) - reparses `$0` to make Awk parsing closer to CLI
    - `awk -f parse_cli_lib.awk -f reparse_cli.awk`
