class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.5/mortar-linux-aarch64.AppImage"
      sha256 "56e9b08447cc765e38da87f8e1afb9ddb9ca5ed4d3c8ccc6511ddc25d97c452e"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.5/mortar-linux-x86_64.AppImage"
      sha256 "79d3aa99e63f161995907d4496b8b43e92c61b18b806a64b820dc108ff19185e"
    end
  end

  def install
    bin.install Dir["mortar-linux-*.AppImage"].first => "mortar"
  end

  def caveats
    <<~EOS
      Homebrew keeps Mortar up to date (brew upgrade mortar); Mortar's own updater stays off.
      The AppImage needs FUSE 2 (libfuse2) on the host.
    EOS
  end

  test do
    assert_path_exists bin/"mortar"
    assert_predicate bin/"mortar", :executable?
  end
end
