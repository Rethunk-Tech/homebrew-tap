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
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.5/rgit-v3.0.5-linux-arm64"
      sha256 "667549dfa33b60aa9eb105534bacfde3808f3c9c010ad13b9d7493281fb3fd0e"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-git-cli/releases/download/v3.0.5/rgit-v3.0.5-linux-amd64"
      sha256 "c774ecb76676c6b550ecf76f797448843119a326bbd558b7366374c09d587e08"
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
