class Asymptote < Formula
  desc "Powerful descriptive vector graphics language"
  homepage "https://asymptote.sourceforge.io"
  # Keep version in sync with manual below
  url "https://downloads.sourceforge.net/project/asymptote/2.90/asymptote-2.90.src.tgz"
  sha256 "8c6956fb808bf44a8f2497295b4fa6bae98c41892b40f3ee8fc758a924707340"
  license "LGPL-3.0-only"

  livecheck do
    url :stable
    regex(%r{url=.*?/asymptote[._-]v?(\d+(?:\.\d+)+)\.src\.t}i)
  end

  bottle do
    sha256 arm64_sonoma:   "dae7a3c6154fe240aa2e9748bc0c2a325ed0779482a0db7be7c75639c1fa6db5"
    sha256 arm64_ventura:  "59a50ebf638ffda33ca65067c45fbe1ab42d1000dd9ef7b2f7c0db4e90d1501c"
    sha256 arm64_monterey: "0483483c2219ed057b07bc39c84815951c8bf4a430ab3b2bfdf0765e53ab187b"
    sha256 sonoma:         "fced302116659ce3dfb6ad7ab767f5993881d0cc6645a7b32f6614767450e9bd"
    sha256 ventura:        "cb74dd408d957f88208b9a9b725cfe5c77d74e6a37a9449738f4f3d84e943f00"
    sha256 monterey:       "1a4222be8f452234ad7d28c36556ee5eb6fe12c65c68525070322ef14cd0e7bf"
    sha256 x86_64_linux:   "463c4c8b0ea9d74de992709343b7bdb0de3074c141c2996238b9137415ad2c7a"
  end

  depends_on "glm" => :build
  depends_on "pkg-config" => :build
  depends_on "fftw"
  depends_on "ghostscript"
  depends_on "gsl"
  depends_on "readline"

  uses_from_macos "bison" => :build
  uses_from_macos "flex" => :build
  uses_from_macos "ncurses"
  uses_from_macos "zlib"

  on_linux do
    depends_on "freeglut"
    depends_on "libtirpc"
    depends_on "mesa"
  end

  resource "manual" do
    url "https://downloads.sourceforge.net/project/asymptote/2.90/asymptote.pdf"
    sha256 "871e323cb373b8397415982d7a48241363590900bde6a606f1dfc3879fb6a54c"
  end

  def install
    odie "manual resource needs to be updated" if version != resource("manual").version

    system "./configure", *std_configure_args

    # Avoid use of MacTeX with these commands
    # (instead of `make all && make install`)
    touch buildpath/"doc/asy-latex.pdf"
    system "make", "asy"
    system "make", "asy-keywords.el"
    system "make", "install-asy"

    doc.install resource("manual")
    (share/"emacs/site-lisp").install_symlink pkgshare
  end

  test do
    (testpath/"line.asy").write <<~EOF
      settings.outformat = "pdf";
      size(200,0);
      draw((0,0)--(100,50),N,red);
    EOF

    system bin/"asy", testpath/"line.asy"
    assert_predicate testpath/"line.pdf", :exist?
  end
end
