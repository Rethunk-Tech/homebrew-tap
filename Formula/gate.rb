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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.2/gate-darwin-arm64"
      sha256 "d5208206d5ecfccdbe3d39e6408b6068ac8e082fea93607c3d660ff29caa628e"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.2/gate-darwin-amd64"
      sha256 "fb769d4e5e40668c97b1719b48906a87e483dc4d156dc31506d506c999a3ee25"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.2/gate-linux-arm64"
      sha256 "0fa2413018df3a709e52e967fe86ca599c80432667cfa262f700e8b1e1d51a79"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.10.2/gate-linux-amd64"
      sha256 "bb0b6e387d4af27b632f9a7932c58a742bba3121f152dcb5fc659e5faf0c4d1e"
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
