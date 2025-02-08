BEGIN {
  NMAX=100000000
  for (; ;) {
    iteration()
    print "sleep"
    system("sleep 5")
  }
}
function iteration(   h) {
  print "allocating..."
  for (i=0; i<NMAX; i++) {
    h[i]
  }
  print "sleep"
  system("sleep 5")
  print "de-allocating"
#  delete h
  #    for (i=0; i<NMAX; i++) {
  #      delete H[i]
  #    }
}