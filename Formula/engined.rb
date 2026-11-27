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
    url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.7/engined-completions-man.tar.gz"
    sha256 "fcd41b1b1bbd62f858409248b60ee1f99c2d80ef53aa99704316370f49481d92"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.7/engined-linux-arm64.tar.gz"
      sha256 "b90ede54bcb48c8b0ec20b821fad59a404cf5d2930dc3f76ccfb41cd3a646be5"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.7/engined-linux-amd64.tar.gz"
      sha256 "907c7f0212944b4ecf602df65583d0fb6aa53f614cf708eda5fc954a7f831842"
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
