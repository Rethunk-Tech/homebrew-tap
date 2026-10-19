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
      url "https://github.com/Rethunk-Tech/heft/releases/download/v0.12.4/heft-linux-arm64"
      sha256 "827e5fd63893bf5220ba43d521a9eff332fbdb7473e6ea51b94075e78d07a345"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/heft/releases/download/v0.12.4/heft-linux-amd64"
      sha256 "d0e16e3203918e715ca25c6ee9b880b6f62097f41c9874d2c4e34190663c5011"
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
