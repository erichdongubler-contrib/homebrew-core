class AwsSdkCpp < Formula
  desc "AWS SDK for C++"
  homepage "https://github.com/aws/aws-sdk-cpp"
  url "https://github.com/aws/aws-sdk-cpp/archive/refs/tags/1.11.465.tar.gz"
  sha256 "3bf855c882b93d72d2da8e4e829ba29b66b85fa28f548fb7499e7a96d6a22315"
  license "Apache-2.0"
  head "https://github.com/aws/aws-sdk-cpp.git", branch: "main"

  livecheck do
    throttle 15
  end

  bottle do
    sha256 cellar: :any,                 arm64_sequoia: "a4b86bd602b051e23fc14fbb67c17b4862306c7c6f0c1a30eab33d3e34395777"
    sha256 cellar: :any,                 arm64_sonoma:  "456d7ebc701de5774d8e7cf75a5b6f8d6e513f9d7529a84db03f5e87f931d2df"
    sha256 cellar: :any,                 arm64_ventura: "8dddf72372d27776133962bd2199074ed176da5929c43af6dfbed6bed96a234b"
    sha256 cellar: :any,                 sonoma:        "d7fc33fd839ad8f93ddf95c8ed496d02bb6f4f6f7c7b1ea9c5a1a6521e83a117"
    sha256 cellar: :any,                 ventura:       "22e845561444df58fbf87c22851710ee6ae66baf4cf780374679bd06015eedce"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0c4658c46354d0bf3cc92f20b2c23a513b2e870478feceb2a0fd6552df3b478a"
  end

  depends_on "cmake" => :build
  depends_on "aws-c-auth"
  depends_on "aws-c-common"
  depends_on "aws-c-event-stream"
  depends_on "aws-c-http"
  depends_on "aws-c-io"
  depends_on "aws-c-s3"
  depends_on "aws-crt-cpp"

  uses_from_macos "curl"
  uses_from_macos "zlib"

  def install
    # Avoid OOM failure on Github runner
    ENV.deparallelize if OS.linux? && ENV["HOMEBREW_GITHUB_ACTIONS"].present?

    linker_flags = ["-Wl,-rpath,#{rpath}"]
    # Avoid overlinking to aws-c-* indirect dependencies
    linker_flags << "-Wl,-dead_strip_dylibs" if OS.mac?

    args = %W[
      -DBUILD_DEPS=OFF
      -DCMAKE_MODULE_PATH=#{Formula["aws-c-common"].opt_lib}/cmake
      -DCMAKE_SHARED_LINKER_FLAGS=#{linker_flags.join(" ")}
      -DENABLE_TESTING=OFF
    ]

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~CPP
      #include <aws/core/Version.h>
      #include <iostream>

      int main() {
          std::cout << Aws::Version::GetVersionString() << std::endl;
          return 0;
      }
    CPP
    system ENV.cxx, "-std=c++11", "test.cpp", "-L#{lib}", "-laws-cpp-sdk-core", "-o", "test"
    system "./test"
  end
end
