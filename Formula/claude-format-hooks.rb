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
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.5/format-dispatch-darwin-arm64"
      sha256 "4d22dde4d540a3f89ca9c6eeb8224c879a668713721cdcb2a42124abff0f3e00"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.5/format-dispatch-darwin-amd64"
      sha256 "47302618780a65dbde01a41ff49c99d9ea60b3f203050624abea255ff5afad19"
    else
      odie "claude-format-hooks is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.5/format-dispatch-linux-arm64"
      sha256 "cf44345f259265c9fbb1b2121692f99131d5f57a63cb16b935e11b853068c91b"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/claude-format-hooks/releases/download/v0.5.5/format-dispatch-linux-amd64"
      sha256 "a83db3d08494103a85de811e030eae08b91d012b1f562ef9d35a179e67ebe38a"
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
