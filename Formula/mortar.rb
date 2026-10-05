class Mortar < Formula
  desc "Desktop mod manager for Stardew Valley: profiles, SMAPI and Nexus Mods downloads"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.2.2/mortar-linux-aarch64.AppImage"
      sha256 "212f87e4df12d2ea6ea3c69ddc70cae692171a122c445cd217ad2b84d5cc0bfd"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.2.2/mortar-linux-x86_64.AppImage"
      sha256 "867b4f6775ae05995f0d7f03cca0f79179a6bdb73fef1783bc319d6a4f6f21b3"
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
