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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.3/gate-darwin-arm64"
      sha256 "e8d70e47d09cd5523954f6628bbf01026754605a2cd80d3da34ce9491cd89865"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.3/gate-darwin-amd64"
      sha256 "6e2e9eb7f61829703329aab39d1e069fa7493836fa203404d8bc6a1823eaa0c3"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.3/gate-linux-arm64"
      sha256 "89c46fcbc462918b35386a4a33cdc2f22dd2bf2440f3fd6738e73fa27c0e5a0b"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.3/gate-linux-amd64"
      sha256 "38c14a3015e1bae8e6f7ec24a15d25792d067a32b4d6773a0a11d6d8701327cc"
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
