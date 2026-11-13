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
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.16/engined-linux-arm64.tar.gz"
      sha256 "4bf0b8b26e4c166f818919cadcb9a6dea90ef0e83ebb8fb4fe39ab3d6aa3d6d3"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.16/engined-linux-amd64.tar.gz"
      sha256 "5a71f59052aa3c9b22d20a2e1aaa2765af7dde4251302a32bb3b4a5f08a0389b"
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
