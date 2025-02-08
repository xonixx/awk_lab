BEGIN {
  NMAX=100000000
  for (; ;) {
    print "allocating..."
    for (i=0; i<NMAX; i++) {
      H[i]
    }
    print "sleep"
    system("sleep 5")
    print "de-allocating"
    delete H
#    for (i=0; i<NMAX; i++) {
#      delete H[i]
#    }
    print "sleep"
    system("sleep 5")
  }
}