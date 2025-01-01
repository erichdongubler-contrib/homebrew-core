class Lutok < Formula
  desc "Lightweight C++ API for Lua"
  homepage "https://github.com/freebsd/lutok"
  url "https://github.com/freebsd/lutok/releases/download/lutok-0.6/lutok-0.6.tar.gz"
  sha256 "07bbb1685a246a3d2a1bbb13536e800033aa3e0a5ad41ce9fc89d94c920e319e"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "4e32874f4a95cdd38f4391253fa9252b443d03fe0bdb8f628f4d118f8ecb5a69"
    sha256 cellar: :any,                 arm64_sonoma:  "154d00c3114fe64469ec54977d189c8f83815af51ef16c95406a0a7885067a09"
    sha256 cellar: :any,                 arm64_ventura: "8a9ab6d781bfb340295d4da2bad20ada63a90a9b9eb4a586eab1d0686d7db9fe"
    sha256 cellar: :any,                 sonoma:        "50ceaa40b7954932f72f101589f03bdf26cf16bfe9c9a3805fd1194d1ff1838f"
    sha256 cellar: :any,                 ventura:       "e4ba0f8494a46eab869c3443a07eb143fcb7e9715e0f5c44261e460c091bebf6"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "82aa5ccf29fda46f215b71698a5e36533e5833e14de3d86c3d8d073810978b0c"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkgconf" => [:build, :test]

  depends_on "atf"
  depends_on "lua"

  def install
    system "glibtoolize", "--force", "--install"
    system "autoreconf", "--force", "--install", "--verbose"

    system "./configure", "--disable-silent-rules", "--enable-atf", *std_configure_args
    system "make"
    ENV.deparallelize
    system "make", "check"
    system "make", "install"
    system "make", "installcheck"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <lutok/state.hpp>
      #include <iostream>
      int main() {
          lutok::state lua;
          lua.open_base();
          lua.load_string("print('Hello from Lua')");
          lua.pcall(0, 0, 0);
          return 0;
      }
    CPP

    flags = shell_output("pkgconf --cflags --libs lutok").chomp.split
    system ENV.cxx, "test.cpp", "-std=c++11", "-o", "test", *flags
    system "./test"
  end
end
