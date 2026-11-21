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
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.1/engined-linux-arm64.tar.gz"
      sha256 "cb76c89cae277c732c10835991841ec575e91ca6ec5f1e40eec000b770b07aa2"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.1/engined-linux-amd64.tar.gz"
      sha256 "1080a76f9c471d9383de8a1c8b9b0ba3b0e3cdadaacc16d39c04b3ffbb2be8f2"
    else
      odie "engined is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"engined"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engined --version")
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    assert_match "agent claude: runs through bunx", shell_output("#{bin}/engined --doctor 2>&1", 1)
  end
end
