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
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.12/engined-linux-arm64.tar.gz"
      sha256 "3f88ea982ee0b1f256b7a1691e9323bb4b808c353742ab46e784e3f00b384b6a"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.12/engined-linux-amd64.tar.gz"
      sha256 "9152856f94bf4fbcfade9e46d86af5b47dccc8684836dcded0b0369213f44336"
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
