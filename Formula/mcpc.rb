require "language/node"

class Mcpc < Formula
  include Language::Node::Shebang

  desc "Universal command-line client for the Model Context Protocol (MCP)"
  homepage "https://github.com/apify/mcpc"
  url "https://registry.npmjs.org/@apify/mcpc/-/mcpc-0.5.1.tgz"
  sha256 "12732e94654d10a99a37aa808b6fb0fb39f707a8ae479a39a66a0b1e5051d5cc"
  license "Apache-2.0"

  depends_on "node"

  def install
    system "npm", "install", *std_npm_args
    # The package's executables ship "#!/usr/bin/env node", so a node earlier in PATH
    # (nvm, asdf, system) would run mcpc against node_modules installed for
    # Homebrew's node — and possibly under a runtime older than the required
    # >= 22.12. Point them at Homebrew's node instead.
    rewrite_shebang detected_node_shebang, *libexec.glob("lib/node_modules/@apify/mcpc/bin/*")
    # Only mcpc goes on PATH: it starts its bridge as `node dist/bridge/index.js`
    # and never runs mcpc-bridge by name.
    bin.install_symlink libexec/"bin/mcpc"
  end

  test do
    ENV["MCPC_HOME_DIR"] = testpath/".mcpc"

    assert_match version.to_s, shell_output("#{bin}/mcpc --version")

    # A fresh MCPC_HOME_DIR has no sessions and no auth profiles.
    listing = JSON.parse(shell_output("#{bin}/mcpc --json"))
    assert_empty listing["sessions"]
    assert_empty listing["profiles"]

    # Unknown session: actionable error, exit code 1 (client error).
    assert_match "Session not found: @nope",
                 shell_output("#{bin}/mcpc @nope tools-list 2>&1", 1)

    # Native-addon canary. @napi-rs/keyring is tied to a Node.js ABI, and mcpc
    # degrades to file-based credential storage when the addon fails to load —
    # so without this check a Node major bump would silently downgrade every
    # user's credential storage instead of failing here and asking for a
    # revision bump.
    keyring = libexec.glob("lib/node_modules/**/@napi-rs/keyring").first
    refute_nil keyring, "@napi-rs/keyring is missing from the install"
    system formula_opt_bin("node")/"node", "-e", "require(#{keyring.to_s.inspect})"
  end
end
