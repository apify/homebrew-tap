require "language/node"

class ApifyCli < Formula
  include Language::Node::Shebang

  desc "Apify command-line interface"
  homepage "https://docs.apify.com/cli"
  url "https://registry.npmjs.org/apify-cli/-/apify-cli-0.19.5.tgz"
  sha256 "bddd03175b0e542737e44ef246f5f7f195901ae4c27b42cd4f9811ee532b3849"
  license "Apache-2.0"

  # TODO: move to `disable!` in about a year
  deprecate! date: "2023-08-30", because: "was moved to homebrew-core, use `brew install apify-cli` instead"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    # We have to replace the shebang in the main executable from "/usr/bin/env node"
    # to point to the Homebrew-provided `node`,
    # because otherwise the CLI will run with the system-provided Node.js,
    # which might be a different version than the one installed by Homebrew,
    # causing issues that `node_modules` were installed with one Node.js version
    # but the CLI is running them with another Node.js version.
    rewrite_shebang detected_node_shebang, libexec/"lib/node_modules/apify-cli/src/bin/run"
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  def caveats
    <<~EOS
      The `apify-cli` formula was moved to homebrew-core,
      and eventually it will stop being maintained in `apify/tap/apify-cli`.
      To reinstall the formula from homebrew-core, run
      ```
      brew uninstall apify-cli
      brew untap apify/tap
      brew update
      brew install apify-cli
      ```
    EOS
  end

  test do
    # Test that the Apify CLI is at all installed and working
    assert_match "apify-cli/#{version}", shell_output("#{bin}/apify --version")
    # Test that the CLI can initialize a new actor
    system "#{bin}/apify", "init", "-y", "testing-actor"
    assert_predicate testpath/".actor/actor.json", :exist?
  end
end
