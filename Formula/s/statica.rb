class Statica < Formula
  desc "Static Analysis meta tool"
  homepage "https://github.com/simpsonjulian/statica"
  url "https://github.com/simpsonjulian/statica/archive/refs/tags/v1.2.9.tar.gz"
  sha256 "ead89c91c758215ced28b1030f5096acac575c4efb4da235b2de6e4ba85c3a93"
  license "MIT"

  depends_on "cmake" => :build
  depends_on "rust" => :build
  depends_on "bearer/tap/bearer"
  depends_on "checkov"
  depends_on "coreutils"
  depends_on "ctags"
  depends_on "jq"
  depends_on "lizard-analyzer"
  depends_on "pmd"
  depends_on "python@3.12"
  depends_on "retire"
  depends_on "ripgrep"
  depends_on "ruby"
  depends_on "semgrep"
  depends_on "trivy"

  resource "sarif-tools" do
    url "https://files.pythonhosted.org/packages/63/e8/04311fbba93a4953eea9c6f2bc09d3b0b815a0fba0cfa74ac6bb95118a0a/sarif_tools-3.0.3.tar.gz"
    sha256 "3983cdfad1c82676cb7726b1e57ce26e01645fb3a4b797eb552d456f418e5ea4"
  end

  resource "semgrep-rules-manager" do
    url "https://files.pythonhosted.org/packages/88/ba/9b8270f99c27f7a22d70836a17cb64e42d0e4601eb3c2a72baa9f6aecfbd/semgrep_rules_manager-0.3.2.tar.gz"
    sha256 "0221eda7c1a42904f428ce0c0339c7e80d47bd0ce5455ead5db854b31948b5ad"
  end

  # Built here rather than depended on as unused-code/formulae/unused: Homebrew
  # won't auto-tap a dependency's third-party tap, so that broke installing statica.
  resource "unused" do
    url "https://github.com/unused-code/unused/archive/refs/tags/0.4.0.tar.gz"
    sha256 "40049863d0f62c8aed394c8fd125ad9082c328858bdeed1cdbbff0ce621a3023"
  end

  def install
    ENV["GEM_HOME"] = libexec

    # Install Python resources
    resources.reject { |r| r.name == "unused" }.each do |r|
      r.stage do
        system "pip3", "install", "--prefix=#{libexec}", "."
      end
    end

    # Build unused into its own prefix: libexec/bin holds RubyGems stubs
    resource("unused").stage do
      system "cargo", "install", *std_cargo_args(root: libexec/"unused")
    end

    # Install Ruby gem dependencies
    system "bundle", "config", "set", "--local", "path", "vendor/bundle"
    system "bundle", "install"

    # Install Ruby gem
    system "gem", "build", "statica.gemspec"
    system "gem", "install", "-V", "--install-dir", libexec, "statica-#{version}.gem"

    # Create wrapper script. statica is a bash script, so point at it directly:
    # libexec/bin/statica is RubyGems' generated stub, which loads it as Ruby
    # and dies with a SyntaxError. Its Ruby helpers use `#!/usr/bin/env ruby`,
    # so put the Homebrew Ruby (keg-only on macOS) first on PATH. ctags goes first
    # too: macOS's /usr/bin/ctags is BSD ctags, which unused_with_ctags rejects.
    path = [formula_opt_bin("ruby"), formula_opt_bin("ctags"), libexec/"unused/bin", "$PATH"].join(":")
    (bin / "statica").write_env_script libexec / "gems/statica-#{version}/statica",
                                       GEM_PATH: "#{libexec}:#{ENV["GEM_PATH"]}",
                                       PATH:     path
  end

  test do
    system "#{bin}/statica", "/tmp"
  end
end
