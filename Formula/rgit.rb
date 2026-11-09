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
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v2.4.1/rgit-v2.4.1-linux-arm64"
      sha256 "a147293e9ff78e9079200abc4ce8786a29f76477cd7f7c56ada6000daa327a59"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v2.4.1/rgit-v2.4.1-linux-amd64"
      sha256 "4ce72a01d7151383770329c84436efa5dbf7097bccbbc7857549647715821fe0"
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
