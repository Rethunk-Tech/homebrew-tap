class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.3/mortar-linux-aarch64.AppImage"
      sha256 "812c2c395ad9512bf455a769d5c306b3c226e683c2d27605284fa66527533569"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.3/mortar-linux-x86_64.AppImage"
      sha256 "68f36e8c93b033f6b657e439751d89ea92bab2ce9d1eb0a18b05fbfea01af21c"
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
