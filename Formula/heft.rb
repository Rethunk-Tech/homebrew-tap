class Heft < Formula
  desc "Read-only Linux TUI that groups process cost by application, user service, and container"
  homepage "https://github.com/Rethunk-Tech/heft"
  license "Apache-2.0"

  livecheck do
    url "https://github.com/Rethunk-Tech/heft/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/heft/releases/download/v0.13.0/heft-linux-arm64"
      sha256 "39a28f87dbfbed01dbe2a5e97bae16e47f0073ad52793a8c1a3f9dc2048f823a"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/heft/releases/download/v0.13.0/heft-linux-amd64"
      sha256 "bac8e2331c2137917ba6a8e1f4fd87f120d86eba00a1c78ebfd47829df887a6d"
    else
      odie "heft is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "heft"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/heft --version")
  end
end
