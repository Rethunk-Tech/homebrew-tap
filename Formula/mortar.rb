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
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.9.0/mortar-linux-aarch64.AppImage"
      sha256 "b8882cb0c5eacd59bd9ada5937a4bc85f090cadbd22de3d21808e6424ea623e6"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.9.0/mortar-linux-x86_64.AppImage"
      sha256 "7baefc213737c2ae223807bccd5c0dd0300dd6f521bbf19257d12a1f4670e282"
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
