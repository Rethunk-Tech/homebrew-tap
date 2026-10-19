class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  livecheck do
    url "https://github.com/Rethunk-Tech/mortar/releases/latest"
    strategy :github_latest
  end

  depends_on :linux
  depends_on "libfuse@2"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.7/mortar-linux-aarch64.AppImage"
      sha256 "e89e1bdb7b2fa551afdb53758f36d9e81550959c53e70dc3699d2e8dce3fa116"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.7/mortar-linux-x86_64.AppImage"
      sha256 "d2d8394a1b83d1d21b2fafb0fc198d6e833e6246c6135aa2372de3879690103b"
    else
      odie "Mortar is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install Dir["mortar-linux-*.AppImage"].first => "mortar"
  end

  def caveats
    <<~EOS
      Homebrew keeps Mortar up to date (brew upgrade mortar); Mortar's own updater stays off.
      The AppImage uses FUSE 2 via the libfuse@2 dependency.
    EOS
  end

  test do
    # brew test gets no FUSE mount on CI runners; the AppImage runtime's extract-and-run mode needs none.
    assert_match version.to_s, shell_output("#{bin}/mortar --appimage-extract-and-run --version")
  end
end
