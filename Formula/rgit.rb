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
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v2.3.0/rgit-v2.3.0-linux-arm64"
      sha256 "86f2bfd03b721c5fb61e1924a92a615efc4a6ebcaea0a9edfa67357ada01ab90"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v2.3.0/rgit-v2.3.0-linux-amd64"
      sha256 "212d5aff60a081478171ffd7ae5ca4a7bdb2099b6684fbbbaa0fccd44da64a83"
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
