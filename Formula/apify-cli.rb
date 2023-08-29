require "language/node"

class ApifyCli < Formula
  desc "Apify command-line interface"
  homepage "https://docs.apify.com/cli"
  url "https://registry.npmjs.org/apify-cli/-/apify-cli-0.18.0.tgz"
  sha256 "28d4e8b032992560a4f842a44e8d107693b1a031560325b90967245c4ed7b628"
  license "Apache-2.0"

  depends_on "node@16"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    # We have to replace the shebang in the main executable from "/usr/bin/env node" to point to the keg-only node@16
    inreplace "#{libexec}/lib/node_modules/apify-cli/src/bin/run", "/usr/bin/env node",
                                                                   "#{Formula["node@16"].opt_bin}/node"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    # Test that the Apify CLI is at all installed and working
    assert_match "apify-cli/#{version}", shell_output("#{bin}/apify --version")
    # Test that the CLI can initialize a new actor
    system "#{bin}/apify", "init", "testing-actor"
    assert_predicate testpath/".actor/actor.json", :exist?
  end
end
