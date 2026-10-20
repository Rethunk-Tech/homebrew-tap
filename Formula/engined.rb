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
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.13/engined-linux-arm64.tar.gz"
      sha256 "edad7d1b6f2da8977e9cb49fe9e8abef88325f4c97947c38d9f7f27fd483ae02"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.13/engined-linux-amd64.tar.gz"
      sha256 "da31065348ad79c9cb18d5dea2b66e73cb3e596a485c4cf780e549b8112e89f9"
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
