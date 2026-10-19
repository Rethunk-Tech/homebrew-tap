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
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.2/format-dispatch-darwin-arm64"
      sha256 "d2f3f2988e8ff7ecd1e1458993ef93cc10b15ead284fd4db614d3c340fa24ba7"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.2/format-dispatch-darwin-amd64"
      sha256 "5315ff8ef3277d396cac5871c0fb2b1fa763c702984e7242d1177560aa7aaa5e"
    else
      odie "claude-format-hooks is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.2/format-dispatch-linux-arm64"
      sha256 "cc3f43c39dea45d2ea0c4184ee5d23616798907c75325d5435a459cc14f0d727"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.2/format-dispatch-linux-amd64"
      sha256 "a8097065d791dacca8b54971374135b0bba67018197bdd9e06c3297d8c9b6577"
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
