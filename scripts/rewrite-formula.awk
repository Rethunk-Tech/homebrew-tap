/url "/ { sub(/download\/v[^\/]*/, "download/" tag); want = /aarch64/ ? arm : x86 }
/sha256 "/ { sub(/"[0-9a-f]+"/, "\"" want "\"") }
{ print }
