#!/usr/bin/awk -f
BEGIN {
  WHAT=ENVIRON["WHAT"]
  FOLDER1="./soft/JSONTestSuite/test_parsing/"
  FOLDER2="./soft/JSONTestSuite/test_transform/"
  Successes = Fails = 0
  run()
}

function run() {
  testFolder(FOLDER1)
  testFolder(FOLDER2,"y")
  print "Successes: " Successes
  print "Fails:     " Fails
}

function testFolder(folder, firstLetter,   cmd,f) {
  cmd = "ls -1 " folder
  while (cmd | getline f) {
    testFile(folder, f, firstLetter)
  }
  close(cmd)
}

function testFile(folder, f, firstLetter,   cmd,res) {
  #  print FOLDER f
  if (!firstLetter)
    firstLetter = substr(f,1,1)
  if ("jq" == WHAT)
    cmd = "cat " folder f " | jq ."
  else if ("jsqry" == WHAT)
    cmd = "cat " folder f " | jsqry"
  else
    cmd = "awk -f json_parser.awk " folder f
    #  cmd = "./soft/bwk -f json_parser.awk " folder f
    #  cmd = "./soft/mawk134 -f json_parser.awk " folder f
    #  cmd = "./soft/gawk51 -f json_parser.awk " folder f
    #  print cmd
  cmd = cmd " >/dev/null 2>&1"
  res = system(cmd)
  printf "%8s : %s\n", (res = analyzeResult(firstLetter, res)) ? "SUCCESS" : "FAIL", f
  res ? Successes++ : Fails++
  close(cmd)
}

function analyzeResult(firstLetter, res) {
  return res == 0 && ("y" == firstLetter||"i" == firstLetter) || res != 0 && firstLetter == "n"
}