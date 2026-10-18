BEGIN { FS = "|"; OFS = "|" }
/^#/ || $0 ~ /^[[:space:]]*$/ { next }
NF != 9 {
  print "parse-tools.awk: expected 9 fields, got " NF > "/dev/stderr"
  exit 1
}
$1 == "" || $2 == "" || $4 == "" || $5 == "" {
  print "parse-tools.awk: name, repo, linux_amd64, and linux_arm64 are required" > "/dev/stderr"
  exit 1
}
$3 != "gpg" && $3 != "https" {
  print "parse-tools.awk: signed must be gpg or https" > "/dev/stderr"
  exit 1
}
{ print; n++ }
END {
  if (n < 1) {
    print "parse-tools.awk: no tools" > "/dev/stderr"
    exit 1
  }
}
