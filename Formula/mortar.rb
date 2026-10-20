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
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.9/mortar-linux-aarch64.AppImage"
      sha256 "e4c4f6b8b52879b595a5726637efb11aed834f50ad4e6488102921e414f9b2b0"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.9/mortar-linux-x86_64.AppImage"
      sha256 "c52a358349df2c2850069d0e515aeac53916d0c5c1570c7bf513b349d60998dc"
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
