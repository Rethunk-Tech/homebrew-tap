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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.0/gate-darwin-arm64"
      sha256 "2e1ba0e9332ce9e23ca94c0c5e20fa30c52ba33250906e9e0e34169c8df3c2d8"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.0/gate-darwin-amd64"
      sha256 "c6b299aa7788c43ab57b27db54477a279a72cd4a45a4c130a6c1544b10964604"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.0/gate-linux-arm64"
      sha256 "690c82cfde753d630d619596df3d3b81a57d2b0f66f4860e574921b0a8103cfa"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.0/gate-linux-amd64"
      sha256 "b2b9dfbb69e8453acb2d4b071f67fd677c01fc75e93830d5230459728950e011"
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
