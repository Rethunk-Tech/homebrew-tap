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
    url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.5/engined-completions-man.tar.gz"
    sha256 "52403487a14b1b21619b301abaf8b31c5b7678f50356cfc605696318a107b91d"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.5/engined-linux-arm64.tar.gz"
      sha256 "aaec83df59092a22b4fbfa005b2912ce1a6c6bf8954f7d34abeefc26e9609d29"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.5/engined-linux-amd64.tar.gz"
      sha256 "d0ff43720a67b01e25f4c62567259b9e2c261c24e7f56baae2183d94bdc85972"
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
