class Rgit < Formula
  desc "Symbol-granular git staging and commits"
  homepage "https://github.com/Rethunk-Tech/rethunk-git-cli"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.0/rgit-v3.0.0-linux-arm64"
      sha256 "e54e90b1b1fe80ef507585e3414a44c6ca9734ed32abe301a895ef78a7dcd0df"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.0/rgit-v3.0.0-linux-amd64"
      sha256 "b49fe2ce5d1657bc8bdc9c1f95f85fedecbe5cbeefd23e9eddf047199a708b37"
    else
      odie "rgit is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "rgit"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rgit --version")
  end
end
