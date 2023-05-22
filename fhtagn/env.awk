BEGIN {
  for (k in ENVIRON) {
    print k " : " ENVIRON[k]
  }
}