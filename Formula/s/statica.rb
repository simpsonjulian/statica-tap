class Statica < Formula
  desc "Static Analysis meta tool"
  homepage "https://github.com/simpsonjulian/statica"
  url "https://github.com/simpsonjulian/statica/archive/refs/tags/v1.2.2.tar.gz"
  sha256 "994e4125d31ef8379e7be96cce76614978d7685eb905ec4dea87611aac97fabb"
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

  def install
    bin.install "statica"
    libexec.install %w[tools.d html_report.rb template.erb csv2sarif]
  end

  test do
    system "bin/statica", "/tmp"
  end
end
