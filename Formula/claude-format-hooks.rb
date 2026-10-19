class ClaudeFormatHooks < Formula
  desc "Claude Code PostToolUse format/lint dispatcher hook"
  homepage "https://github.com/Rethunk-Tech/claude-format-hooks"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/latest"
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.3/format-dispatch-darwin-arm64"
      sha256 "ae146a67edab9da3d306b8a1891d48016121a5f1d5b5746757eb807cd2f01b64"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.3/format-dispatch-darwin-amd64"
      sha256 "46c436372ba76b0bfbb6a18d817d87a153dd63390d2072b03b507d222e346700"
    else
      odie "claude-format-hooks is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.3/format-dispatch-linux-arm64"
      sha256 "acd0a65424432e4de67d2de9229115f2177943ed85ddd3f8cecfaf68fb1713a6"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.3/format-dispatch-linux-amd64"
      sha256 "e3ea87b9c64d233e57fec1bbc82204016da79d0c2f809a5667a89e1307783766"
    else
      odie "claude-format-hooks is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "format-dispatch"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/format-dispatch --version")
  end
end
