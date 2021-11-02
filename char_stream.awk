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
function getChar(   c,prev) {
  if (!Pos) {
    Pos=1
    PosInLine=1
    if ((getline CurrentLine) <= 0) {
      #      print 111
      CurrentLine=""
      return
    }
    #    print 111111, CurrentLine
  }
  if (!CurrentLine && 1==PosInLine)
    return "\n"
  if (!(c = 0==PosInLine ? "\n" : substr(CurrentLine,PosInLine,1))) { # line ended
    prev=CurrentLine
    if ((getline CurrentLine) <= 0) {
      #      print 222
      CurrentLine=""
      return
    }
    #    print 222222, CurrentLine
    if (prev) {
      PosInLine = 0
      c = "\n"
    } else {
      PosInLine=1
      c = substr(CurrentLine,PosInLine,1)
    }
  }
  return c
}

function advance() {
  Pos++
  PosInLine++
}