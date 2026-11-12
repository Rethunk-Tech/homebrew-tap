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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.7.0/gate-darwin-arm64"
      sha256 "ef1b81e47f90ead8cfc08c1a92ee58aac8107d5cb6e8608013ff006035ad1008"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.7.0/gate-darwin-amd64"
      sha256 "1cf7b1e5c9c03c275cda0e92ff0f666bea7538889f2582bc65ec764851794077"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.7.0/gate-linux-arm64"
      sha256 "0466e0319da1cb782595c99365cf6df54261b96d3ee922dc748550ee02f3614e"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.7.0/gate-linux-amd64"
      sha256 "2ff81e604be7f0e49bafffd924d3f62ce6b6d92fd26aae95fdf9768a6890651b"
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
