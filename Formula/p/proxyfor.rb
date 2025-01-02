class Proxyfor < Formula
  desc "Proxy CLI for capturing and inspecting HTTP(S) and WS(S) traffic"
  homepage "https://github.com/sigoden/proxyfor"
  url "https://github.com/sigoden/proxyfor/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "f4e2340dbce232333ce05473b75f3b1eacf27d1699071b52a9cf420a8c47fd96"
  license "Apache-2.0"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "proxyfor 0.5.0", shell_output("#{bin}/proxyfor --version")

    read, write = IO.pipe
    port = free_port
    pid = fork do
      exec "#{bin}/proxyfor --dump -l 127.0.0.1:#{port}", out: write
    end

    sleep 5
    system "curl -A 'HOMEBREW' -x http://127.0.0.1:#{port} http://brew.sh/ > /dev/null 2>&1"

    output = read.read_nonblock(256)
    assert_match "# GET http://brew.sh/ 301", output
    assert_match "user-agent: HOMEBREW", output
  ensure
    Process.kill("TERM", pid)
  end
end
