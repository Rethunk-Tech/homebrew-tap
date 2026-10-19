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
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.10/engined-linux-arm64.tar.gz"
      sha256 "89f773255eb3d2a7cf2e543cb5dc351935b9351ca2b87428cad9dace09eae924"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.10/engined-linux-amd64.tar.gz"
      sha256 "e75b269d2b40b5bf04059d23658df1e15a256263c04baaca3f7c9d156268d579"
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
