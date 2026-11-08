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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.10/gate-darwin-arm64"
      sha256 "197b65d78e870f457806e292f6a3bcfcb8577fa0158aee8448d4c9cb297fd496"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.10/gate-darwin-amd64"
      sha256 "dc0c49561d8232fbef9b3d270703dbf71a06e72c4f43c58306111008937006aa"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.10/gate-linux-arm64"
      sha256 "7494b9978e768ecf23a5b36f4fbce0a8dde7abf2bea8b6072d3bc691e809d3af"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.10/gate-linux-amd64"
      sha256 "63babffa002eac35cdcd9a9173cdceab31458446685e51d12f3de3b6ad341338"
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
