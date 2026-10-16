class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.2/mortar-linux-aarch64.AppImage"
      sha256 "a4d5b5b600e940b1349984602b87046655305c281acf27ffee262c6d7f2af5c7"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.2/mortar-linux-x86_64.AppImage"
      sha256 "50ae2dfdecfa113417d6e8a8ea579dd09f6d0575b09c77480c06cce1fdefbc1e"
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
