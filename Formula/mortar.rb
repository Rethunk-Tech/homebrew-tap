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
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.5/mortar-linux-aarch64.AppImage"
      sha256 "56e9b08447cc765e38da87f8e1afb9ddb9ca5ed4d3c8ccc6511ddc25d97c452e"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.5/mortar-linux-x86_64.AppImage"
      sha256 "79d3aa99e63f161995907d4496b8b43e92c61b18b806a64b820dc108ff19185e"
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
    assert_match version.to_s, shell_output("#{bin}/mortar --version")
  end
end
