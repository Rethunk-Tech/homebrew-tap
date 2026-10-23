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
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.4/format-dispatch-darwin-arm64"
      sha256 "9c6c4cc8319cf78e5fedd0a7fbdd4f35bc7fa65a39754e4fd6765257e5013da3"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.4/format-dispatch-darwin-amd64"
      sha256 "0f29f2e9b439a0b916c099f9c970900d93f3a86c2de36002a1d37fcdded4516c"
    else
      odie "claude-format-hooks is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.4/format-dispatch-linux-arm64"
      sha256 "4b6da40bc49b09d2fca625a8488b38424a2a7a4c653ed3c9bed0a0623404b94e"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.4/format-dispatch-linux-amd64"
      sha256 "5d627adab56dfa10e35d9864c0d84cc6e4f09a69d2dc4b8375cf9c6eb9f356e2"
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
