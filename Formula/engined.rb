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
    url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.3/engined-completions-man.tar.gz"
    sha256 "34a31d4584c1269225883787a60d142136f06cbf90b3e79c99609001aa712197"
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.3/engined-linux-arm64.tar.gz"
      sha256 "cda439028a1f37e174e87801fef06905ad69305abadfe52f6195d766b9d70f67"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.3.3/engined-linux-amd64.tar.gz"
      sha256 "500959d8326edcc1b845bcd00b470e85d8cb4f3db2b3d351b49e4b50a1bb98dc"
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
