class Engined < Formula
  desc "Local model door: the sole owner of inference containers on one box"
  homepage "https://github.com/Rethunk-Tech/engined"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/engined/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  resource "completions-man" do
    url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.2/engined-completions-man.tar.gz"
    sha256 "be6dd93b4cb30e95d548666fa00cab9025b79e232a58bdc96ba9bc7fe1bfbd74"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.2/engined-linux-arm64.tar.gz"
      sha256 "1b88e6ef024f6f577bb97eaf75c4bf4ddbaaa6de39fa4a43a1d535b35f3cfa31"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.2/engined-linux-amd64.tar.gz"
      sha256 "ac9603076e279d2106131de56c9a02d79a44ed61d1cd32d98efb382ad300ee5c"
    else
      odie "engined is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    libexec.install Dir["*"]
    bin.install_symlink libexec/"engined"
    resource("completions-man").stage do
      bash_completion.install "engined.bash" => "engined"
      zsh_completion.install "_engined"
      fish_completion.install "engined.fish"
      man1.install "engined.1"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engined --version")
    ENV["XDG_CONFIG_HOME"] = testpath/"config"
    assert_match "agent claude: runs through bunx", shell_output("#{bin}/engined --doctor 2>&1; true")
  end
end
