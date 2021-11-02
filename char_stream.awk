#
# Awk is not able to distinguish 'a' vs 'a\n' inputs, so let's parse 2 as 1
#
# depends on RS="\n" (default)
#
# globals:
#   CurrentLine
#   PosInLine
#   Pos
#
function getChar(   c) {
  if (!Pos) {
    Pos=1
    PosInLine=1
    if (getline CurrentLine <= 0)
      return CurrentLine=""
  }
  if (!(c = 0==PosInLine ? "\n" : substr(CurrentLine,PosInLine,1))) { # line ended
    if (getline CurrentLine <= 0)
      return CurrentLine=""
    PosInLine = 0
    c = "\n"
  }
  return c
}

function advance() {
  Pos++
  PosInLine++
}