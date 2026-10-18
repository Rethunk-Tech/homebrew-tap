BEGIN { FS = "|"; OFS = "|" }
/^#/ || $0 ~ /^[[:space:]]*$/ { next }
NF != 13 {
  print "parse-tools.awk: expected 13 fields, got " NF > "/dev/stderr"
  exit 1
}
$1 == "" || $2 == "" || $4 == "" || $5 == "" {
  print "parse-tools.awk: name, repo, linux_amd64, and linux_arm64 are required" > "/dev/stderr"
  exit 1
}
$3 != "gpg" && $3 != "sha256sums" && $3 != "sha256" {
  print "parse-tools.awk: checksum must be gpg, sha256sums, or sha256" > "/dev/stderr"
  exit 1
}
$3 != "gpg" && $12 != "bare" && $12 != "archive" {
  print "parse-tools.awk: install must be bare or archive" > "/dev/stderr"
  exit 1
}
$3 != "gpg" && $13 == "" {
  print "parse-tools.awk: cmd is required" > "/dev/stderr"
  exit 1
}
{ print; n++ }
END {
  if (n < 1) {
    print "parse-tools.awk: no tools" > "/dev/stderr"
    exit 1
  }
}
