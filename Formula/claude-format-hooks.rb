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
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.6/format-dispatch-darwin-arm64"
      sha256 "554f28d2a51c68217885ebefa43d8b2736ae1b1b4c30397de5f49463bb6aa469"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.6/format-dispatch-darwin-amd64"
      sha256 "424b9ef46fb2b24a9fc6930ea2ca1222a6e4b5fa2da35ca7b65d0317bc871803"
    else
      odie "claude-format-hooks is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.6/format-dispatch-linux-arm64"
      sha256 "f309f28a6f5fdc521a8f009f13b1b2fa5d4079e4d419fddc00b9afb4aa068b7b"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.6/format-dispatch-linux-amd64"
      sha256 "132e9b699d1c4e1c6e7da75af0a0f3fdf20c15cc4de08096dda981fd4911c32c"
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
