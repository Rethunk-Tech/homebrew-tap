class Heft < Formula
  desc "Read-only Linux TUI that groups process cost by application, user service, and container"
  homepage "https://github.com/Rethunk-Tech/heft"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/Rethunk-Tech/heft/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/heft/releases/download/v0.12.5/heft-linux-arm64"
      sha256 "486c5d966d795c5f89904b9b63c6ce7e460b95d9e0f24df138e644497a02bdad"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/heft/releases/download/v0.12.5/heft-linux-amd64"
      sha256 "6e4aceee2db55aafabff7ae24f211f30c80d481f9868babff115a0a0672194c4"
    else
      odie "heft is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "heft"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/heft --version")
  end
end
