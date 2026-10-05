class Mortar < Formula
  desc "Desktop mod manager for Stardew Valley: profiles, SMAPI and Nexus Mods downloads"
  homepage "https://mortar.rethunk.tech/"
  version "0.2.1"
  license "AGPL-3.0-only"

  on_intel do
    url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.2.1/mortar-linux-x86_64.AppImage"
    sha256 "7befca6e468ffee52f466b86a80beed2673148af022583cc5d3e161e45607236"
  end
  on_arm do
    url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.2.1/mortar-linux-aarch64.AppImage"
    sha256 "adce91ce885ef23d01a654398037682fa4f6ea2ea2cbdf116d449daf6e514a12"
  end

  depends_on :linux

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
