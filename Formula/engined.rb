class Engined < Formula
  desc "Local model door: the sole owner of inference containers on one box"
  homepage "https://github.com/Rethunk-Tech/engined"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/engined/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  depends_on "bun"

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.9/engined-linux-arm64.tar.gz"
      sha256 "fbe0d373039704673bb914d728a30d5e223233bd5c1c18311d0e0ede1d7426de"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/engined/releases/download/v0.2.9/engined-linux-amd64.tar.gz"
      sha256 "9fd5c4ff1ea201b79090c72f66a58db6b3d0ff7520277fbd8ebe3ffee53e537d"
    else
      odie "engined is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    libexec.install Dir["*"]
    (bin/"engined").write <<~EOS
      #!/bin/bash
      exec "#{Formula['bun'].opt_bin}/bun" "#{libexec}/dist/main.js" "$@"
    EOS
    chmod 0755, bin/"engined"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/engined --version")
  end
end
