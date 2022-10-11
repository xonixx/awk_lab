

function assertEquals(expected,actual,message) {
  if (expected != actual) {
    message = message (message ? ": " : "") "expected=" expected ", actual=" actual
    print message > "/dev/stderr"
  }
}