class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.4/mortar-linux-aarch64.AppImage"
      sha256 "92658268eb5833e0514de006751c555d6972321602804f10fe1850dfa8c97728"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.4/mortar-linux-x86_64.AppImage"
      sha256 "36ac2f7062d9dbf1751d63af5ba4d98b2b918e23c0d76ca952743b9f0729a588"
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
