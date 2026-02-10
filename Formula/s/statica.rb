class Statica < Formula
  desc "Static Analysis meta tool"
  homepage "https://github.com/simpsonjulian/statica"
  url "https://github.com/simpsonjulian/statica/archive/refs/tags/v1.2.6.tar.gz"
  sha256 "00b5fa44e64fa9b5e3040dc306f880efc145f231bc3ecd6819e75280869064ca"
  license "MIT"


  depends_on 'bearer/tap/bearer'
  depends_on 'checkov'
  depends_on 'coreutils'
  depends_on 'jq'
  depends_on 'lizard-analyzer'
  depends_on 'pmd'
  depends_on 'python@3.12'
  depends_on 'retire'
  depends_on 'ruby'
  depends_on 'semgrep'
  depends_on 'trivy'

  resource 'sarif-tools' do
    url 'https://files.pythonhosted.org/packages/63/e8/04311fbba93a4953eea9c6f2bc09d3b0b815a0fba0cfa74ac6bb95118a0a/sarif_tools-3.0.3.tar.gz'
    sha256 '3983cdfad1c82676cb7726b1e57ce26e01645fb3a4b797eb552d456f418e5ea4'
  end

  resource 'semgrep-rules-manager' do
    url 'https://files.pythonhosted.org/packages/88/ba/9b8270f99c27f7a22d70836a17cb64e42d0e4601eb3c2a72baa9f6aecfbd/semgrep_rules_manager-0.3.2.tar.gz'
    sha256 '0221eda7c1a42904f428ce0c0339c7e80d47bd0ce5455ead5db854b31948b5ad'
  end

  def install
    ENV['GEM_HOME'] = libexec

    # Install Python resources
    resources.each do |r|
      r.stage do
        system 'pip3', 'install', "--prefix=#{libexec}", '.'
      end
    end

    # Install Ruby gem dependencies
    system 'bundle', 'config', 'set', '--local', 'path', 'vendor/bundle'
    system 'bundle', 'install'

    # Install Ruby gem
    system 'gem', 'build', 'statica.gemspec'
    system 'gem', 'install', '-V', '--install-dir', libexec, "statica-#{version}.gem"

    # Create wrapper script
    (bin / 'statica').write_env_script libexec / 'bin/statica', GEM_PATH: "#{libexec}:#{ENV['GEM_PATH']}"
  end

  test do
    system "#{bin}/statica", '/tmp'
  end
end
