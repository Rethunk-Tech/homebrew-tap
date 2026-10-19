class Engined < Formula
  desc "Local model door: the sole owner of inference containers on one box"
  homepage "https://github.com/Rethunk-Tech/engined"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/engined/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.11/engined-linux-arm64.tar.gz"
      sha256 "f627350c0a1da18014297580462b4a41c97acf783ef1f24bd9ff8b3b2ac5f81f"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.11/engined-linux-amd64.tar.gz"
      sha256 "08992112d50e320946eb8b3b6b725763feba3993c00d4b20703ffca05ae0f9dd"
    else
      odie "engined is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install "engined"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engined --version")
  end
end
