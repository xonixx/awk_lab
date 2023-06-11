BEGIN {
  print f1("aaa")
  Arr[1]
  Arr[2]
  print f1(Arr)
}
function f1(v) {
  return length(v)
}