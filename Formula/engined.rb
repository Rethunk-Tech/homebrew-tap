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
    url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.6/engined-completions-man.tar.gz"
    sha256 "e3e5fa644261445b96accdb3f9312e4076624d4cda483c356687c729181aeab7"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.6/engined-linux-arm64.tar.gz"
      sha256 "dd70c5c1750d6c7c35cea9bf71c44dc619d35584567454b670940fa2e27ca64a"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.6/engined-linux-amd64.tar.gz"
      sha256 "613c44a898e340abca79c6a95c9cb980602b52d7d2042d52c6004d887ba27900"
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
