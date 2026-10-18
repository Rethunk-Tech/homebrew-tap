BEGIN {
  if (tag == "" || x86 == "" || arm == "") {
    print "rewrite-formula.awk: tag, x86, and arm are required" > "/dev/stderr"
    exit 1
  }
}
/url "/ && /AppImage/ {
  sub(/download\/v[^\/]*/, "download/" tag)
  want = /aarch64/ ? arm : x86
  urls++
}
/sha256 "/ {
  if (want == "") {
    print "rewrite-formula.awk: sha256 before url" > "/dev/stderr"
    exit 1
  }
  sub(/"[0-9a-f]+"/, "\"" want "\"")
  hashes++
}
{ print }
END {
  if (urls != 2 || hashes != 2) {
    print "rewrite-formula.awk: expected 2 url lines and 2 sha256 lines" > "/dev/stderr"
    exit 1
  }
}
