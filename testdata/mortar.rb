class Mortar < Formula
  desc "Desktop mod manager for PC games: profiles and Nexus, GitHub, Thunderstore mods"
  homepage "https://mortar.rethunk.tech/"
  license "AGPL-3.0-only"

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.0/mortar-linux-aarch64.AppImage"
      sha256 "ffb51fca9ae762f9eb2cd3cc13911aa1bfba00c6e561a452cb951184b9aff042"
    else
      url "https://github.com/Rethunk-Tech/mortar/releases/download/v0.3.0/mortar-linux-x86_64.AppImage"
      sha256 "4913687e6404afab8845e9bfffd428711ff5fb7e1db1fb0ea571cd5a5cc500dd"
    end
  end
end
