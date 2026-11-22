class Rgit < Formula
  desc "Symbol-granular git staging and commits"
  homepage "https://github.com/Rethunk-Tech/rethunk-git-cli"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/latest"
    strategy :github_latest
  end

  depends_on :linux

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.6/rgit-v3.0.6-linux-arm64"
      sha256 "342436f796cb70b2fd5ec43eaf130f2949a2ef00c97b45541e9a24be02d15c97"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.6/rgit-v3.0.6-linux-amd64"
      sha256 "ec1f5021b55ddd27aebbe7642ee99640779c8c4b6798e9337deb4a4dc99ec834"
    else
      odie "rgit is only packaged for Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "rgit"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/rgit --version")
  end
end
