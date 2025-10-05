class Statica < Formula
  desc "Static Analysis meta tool"
  homepage "https://github.com/simpsonjulian/statica"
  url "https://github.com/simpsonjulian/statica/archive/refs/tags/v1.2.5.tar.gz"
  sha256 "4e14a7a76c65c3a896c19750e5d7ac7b421732e021a5754d61747ce2fca64aa2"
  license "MIT"
  depends_on "checkov"
  depends_on "jq"
  depends_on "lizard-analyzer"
  depends_on "pmd"
  depends_on "retire"
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

  def install
    bin.install "statica"
    libexec.install %w[tools.d html_report.rb template.erb csv2sarif]
  end

  test do
    system "bin/statica", "/tmp"
  end
end
