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
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.2/rgit-v3.0.2-linux-arm64"
      sha256 "effa5499a492eacb259f46aec9a936555b697d0fa5c5e24afe4b6df5007f785c"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.2/rgit-v3.0.2-linux-amd64"
      sha256 "df8e2a136b7bf5c110d03e70e6aacebac93b4af009d0af6695817b449441e17b"
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
