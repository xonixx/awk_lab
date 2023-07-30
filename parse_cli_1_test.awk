#include parse_cli_1_lib.awk
#include parse_cli_N_test.awk

function parseAbstract(line, res) {
  return parseCli_1(line, res)
}