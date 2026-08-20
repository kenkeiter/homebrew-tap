class Plasticturtle < Formula
  desc "Pretty good sandbox: ephemeral Tart VMs with a domain-based egress firewall"
  homepage "https://github.com/kenkeiter/plasticturtle"
  url "https://github.com/kenkeiter/plasticturtle/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d2c8ff9f14a9971e2904e9fd5254dd31a760a2a6d8868f53820ed526529c0ce6"
  license "MIT"
  head "https://github.com/kenkeiter/plasticturtle.git", branch: "main"

  depends_on "go" => :build
  depends_on arch: :arm64
  depends_on "cirruslabs/cli/tart"
  depends_on :macos

  def install
    # std_go_args already supplies -s -w; only the version stamp is ours.
    ldflags = "-X main.version=v#{version}"
    # Both binaries must land in the same directory: `plasticturtle setup` looks
    # for plasticturtle-softnet-shim next to the running binary.
    system "go", "build", *std_go_args(ldflags:, output: bin/"plasticturtle"),
                          "./cmd/plasticturtle"
    system "go", "build", *std_go_args(ldflags:, output: bin/"plasticturtle-softnet-shim"),
                          "./cmd/plasticturtle-softnet-shim"

    # Shorter name for daily use. The binary reports whichever name it was
    # invoked as, so its messages stay copy-pasteable either way. If this ever
    # collides with another formula, this one line is the whole fix.
    bin.install_symlink bin/"plasticturtle" => "turtle"
  end

  def caveats
    <<~EOS
      Installed as `plasticturtle`, with `turtle` as a shorter alias.

      Add the following line to your ~/.zshrc:
        source <(turtle zsh-hook)

      If you wish to use the outbound firewall, you will need to run
      `turtle setup` now and after each upgrade to Plastic Turtle. This requires
      root due to Apple Virtualization Framework constraints. Plastic Turtle
      itself does not require root permissions on an ongoing basis.
        turtle setup
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/plasticturtle --version")

    # Both names reach the same binary, and each reports itself — that is what
    # makes the error messages copy-pasteable. Run from a directory with no
    # .plasticturtle, so the advice names the init subcommand.
    assert_match "run turtle init", shell_output("#{bin}/turtle shell 2>&1", 1)
    assert_match "run plasticturtle init", shell_output("#{bin}/plasticturtle shell 2>&1", 1)
  end
end
