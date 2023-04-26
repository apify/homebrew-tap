require "language/node"

class ApifyCli < Formula
  desc "Apify command-line interface"
  homepage "https://docs.apify.com/cli"
  url "https://registry.npmjs.org/apify-cli/-/apify-cli-0.16.0.tgz"
  sha256 "b61a6059b9f0e13f6780ecf04b365efcc064ecd46341f663581b2a990b37f040"
  license "Apache-2.0"

  depends_on "node@16"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    # We have to replace the shebang in the main executable from "/usr/bin/env node" to point to the keg-only node@16
    inreplace "#{libexec}/lib/node_modules/apify-cli/src/bin/run", "/usr/bin/env node", "#{Formula["node@16"].opt_bin}/node"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    assert_match "apify-cli/#{version}", shell_output("#{bin}/apify --version")
  end
end
