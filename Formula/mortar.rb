class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.1/mortar-linux-aarch64.AppImage"
      sha256 "bd11b4e4f0423e1a0c0e4d1a87dbaa3e3e38e1b8ca4254d7836ed28c7865e687"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.1/mortar-linux-x86_64.AppImage"
      sha256 "0e1dc926ebc23115739130b44038aed29f7da3854abc4555276c0c738a0fce16"
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
