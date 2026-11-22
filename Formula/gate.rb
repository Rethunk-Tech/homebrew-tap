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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.6/gate-darwin-arm64"
      sha256 "97663b0247e34e85b2fd25dc99b8c5bd70bf555b7b0daacdfb01a74a414e93bd"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.6/gate-darwin-amd64"
      sha256 "ee131bd4ba015cd386c8d15dfc0094045b3305cd4835bbb7f6c9c73d19da7db4"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.6/gate-linux-arm64"
      sha256 "1d9c530bc2072022bee56def00e6a05cd077772d32c945803d985b58b9f372f2"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.6/gate-linux-amd64"
      sha256 "6e8813c047cc745a5c296f5b360b60d92133425245b26b2c5efa5fe5eb9ec6b5"
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
