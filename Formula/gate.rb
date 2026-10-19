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
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.9/gate-darwin-arm64"
      sha256 "46a6345b02c54c1753348263e85635ea2ca3b0fe28ab882b0c308c8758274327"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.9/gate-darwin-amd64"
      sha256 "4e1f108f639bb8cf35046d5f973910ae9acd32a95e364e4830a08fe9c65127d9"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.9/gate-linux-arm64"
      sha256 "56595f6faa42c759f8e96871fb6e793928e762003194a91b697416c987ddf4aa"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.9/gate-linux-amd64"
      sha256 "faba32bf84293c02d3327cb885d8b129b868cb5620db5e388b20b03ba6992c30"
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
