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
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.13/mortar-linux-aarch64.AppImage"
      sha256 "2b5aecd42ef9ce67ee79a2c06bc3ca79f14ebea7a4aae9484add871f83c8330b"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.13/mortar-linux-x86_64.AppImage"
      sha256 "25b5f1affefbe0b2460841881b40a61c37d46e3d540ebad7cb627f8f1709a411"
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
