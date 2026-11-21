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
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.0/engined-linux-arm64.tar.gz"
      sha256 "719a9628ff91c30d2cbbcc8214fccaac56e069826e25df059f8b70b911a8cfe6"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.0/engined-linux-amd64.tar.gz"
      sha256 "ff33995f344466154f5956b05fe69d5a7421973eccc964661b1a63b171cb93ce"
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
