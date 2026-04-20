class Cdktn < Formula
  desc "CDK Terrain CLI (community fork of CDK for Terraform)"
  homepage "https://github.com/open-constructs/cdk-terrain"
  url "https://github.com/open-constructs/cdk-terrain/archive/refs/tags/v0.22.1.tar.gz"
  sha256 "520e06c2c510ff988a25a05e1c5cc11718430b4be0420eab532b65666088a77a"
  license "MPL-2.0"

  depends_on "yarn" => :build
  depends_on "node@20"
  depends_on "terraform"

  def install
    # Install monorepo deps from the repo root. Lifecycle scripts must run —
    # cdktn packages use prepare/postinstall hooks for internal codegen.
    system "yarn", "install", "--frozen-lockfile"

    # Upstream keeps "version": "0.0.0" in source and bumps it via lerna only
    # at npm publish time. Inject the formula version so `cdktn --version`
    # reports the released tag.
    inreplace "packages/cdktn-cli/package.json",
              /"version":\s*"0\.0\.0"/,
              "\"version\": \"#{version}\""

    # Build all workspaces (tsc + jsii). The CLI's esbuild bundle marks several
    # workspace packages (cdktn core, @cdktn/hcl2cdk, @cdktn/hcl-tools, ...) as
    # externals, so the core library's jsii build output is required at runtime.
    system "yarn", "build"

    # Ship node_modules + packages so the bundle can resolve its externals.
    libexec.install "node_modules", "packages", "package.json", "yarn.lock"
    (bin/"cdktn").write_env_script libexec/"packages/cdktn-cli/bundle/bin/cdktn",
      PATH: "#{Formula["node@20"].opt_bin}:$PATH"
  end

  def caveats
    <<~EOS
      cdktn shells out to `terraform` at runtime — installed as a dependency
      and available on PATH.

      On first use, `cdktn init` may download additional language toolchains
      (Python, Go, Java, .NET) depending on the target language of your project.
    EOS
  end

  test do
    assert_predicate libexec/"packages/cdktn-cli/bundle/bin/cdktn", :executable?
    assert_path_exists libexec/"node_modules/cdktn"
    assert_match version.to_s, shell_output("#{bin}/cdktn --version")
    system bin/"cdktn", "--help"
  end
end
