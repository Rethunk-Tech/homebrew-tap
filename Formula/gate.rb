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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.9.0/gate-darwin-arm64"
      sha256 "c1386ac6a17f0b144c32e379f0460bcf1edb8557fdc09ea9125e8fb82ab09b46"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.9.0/gate-darwin-amd64"
      sha256 "4d68a47982404c9a05ae54a903c58cf8b84741af24176b133a701c538ab8bfc3"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.9.0/gate-linux-arm64"
      sha256 "beb081ec16175ed9b3ec69fca43bd0b41c27232343c7b8e85a26dcf0253ffb1b"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.9.0/gate-linux-amd64"
      sha256 "84011e4b8e9d181efba86ef616be07c8bf6a140b789ac204ef6bad11602f3f9d"
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
