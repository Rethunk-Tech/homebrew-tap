class Gate < Formula
  desc "Runs a project's gates concurrently, keeps every byte in a log"
  homepage "https://github.com/Rethunk-Tech/rethunk-gate-cli"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/latest"
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.5/gate-darwin-arm64"
      sha256 "292fa749ee5da2c6f48cd58bcce0fcd5f10c66ecca19084352312ea6620bfce2"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.5/gate-darwin-amd64"
      sha256 "82b80e467c7798ae49ac3761d94a3dd9b4e2433e48a0cbc7d6d8ea14e0598d5b"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.5/gate-linux-arm64"
      sha256 "c66c7804e684859b66a99cfdd3ff013d5fdd2ae799b84760a44aec418f5558f7"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.5/gate-linux-amd64"
      sha256 "a10f4d6485a3eca467d9b4c6cdeb7894ec114ab0158b592a912db3e2462ab0c8"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "gate"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gate --version")
  end
end
