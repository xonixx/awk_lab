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
    if ((getline CurrentLine) <= 0) {
#      print 111
      CurrentLine=""
      return
    }
#    print 111111
#    if (!CurrentLine)
#      PosInLine = 0
  }
  if (!(c = PosInLine <= 0 ? "\n" : substr(CurrentLine,PosInLine,1))) { # line ended
    if ((getline CurrentLine) <= 0) {
#      print 222
      CurrentLine=""
      return
    }
#    print 222222
#    PosInLine = !CurrentLine ? -1 : 0
    PosInLine = 0
    c = "\n"
  }
  return c
}

function advance() {
  Pos++
  PosInLine++
}