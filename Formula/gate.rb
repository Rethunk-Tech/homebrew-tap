class Gate < Formula
  desc "Runs a project's gates concurrently, keeps every byte in a log"
  homepage "https://github.com/Rethunk-Tech/rethunk-gate-cli"
  license "MIT"

  livecheck do
    url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/latest"
    strategy :github_latest
  end

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.8/gate-darwin-arm64"
      sha256 "f279e22bfc8e52e6e60005d6548e8fb7919bfbd08ebdf86add442ae55a917343"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.8/gate-darwin-amd64"
      sha256 "9413694816c8910d177358f4cf21afb43a1c394213d8b0f5edf238e877ee127f"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.8/gate-linux-arm64"
      sha256 "f0e006e612412cfee90b6bdf2c1fd808ed89c6edc0cb8627e170e2575d73a577"
    elsif Hardware::CPU.intel?
      url "https://github.com/Rethunk-Tech/rethunk-gate-cli/releases/download/v0.6.8/gate-linux-amd64"
      sha256 "186c90a86db7abc0d4403b8ef58e5b442db4da36754e451ae300ec1acb33ec7b"
    else
      odie "gate is only packaged for macOS and Linux x86_64 and aarch64"
    end
  end

  def install
    bin.install File.basename(stable.url) => "gate"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/gate --version")
  end
end
