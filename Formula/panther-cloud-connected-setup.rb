class PantherCloudConnectedSetup < Formula
  desc "Tools for Panther deployments"
  homepage "https://github.com/panther-labs/panther-cli"
  # Specify the version of the release. This will be used in the binary URLs.
  # You will update this and the sha256 checksums for each new release.
  version "0.0.19"
  license "Apache-2.0"

  # For HEAD installs, we build from source.
  head "https://github.com/panther-labs/panther-cli.git", branch: "main"

  # livecheck block to find new versions.
  # It's good practice to point directly to the releases page.
  livecheck do
    url :stable
    regex(%r{href=["']?[^"' >]*?/tag/v?(\d+(?:\.\d+)+)["' >]}i)
    strategy :page_match # Or :github_latest
  end

  # Go is needed as a build dependency for HEAD installs.
  # For binary installs, it won't be used for the installation itself.
  depends_on "go" => :build

  on_macos do
    on_intel do # x86_64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Darwin_x86_64.tar.gz"
      sha256 "9b7dbaa06d42fa129d9e67f782a7dfac2ca3c734981ee9d33de0bdb8e6a4454c"
    end
    on_arm do # arm64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Darwin_arm64.tar.gz"
      sha256 "aa74dc03cdcc5a0a2b594146956a3327b9490443335c8541e778e5bd815654f8"
    end
  end

  on_linux do
    on_intel do # x86_64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Linux_x86_64.tar.gz"
      sha256 "9a9e2b0504f4dbe628d8889b8348705ee96c50ff25ebd8618dcb1f5077886681"
    end
    on_arm do # arm64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Linux_arm64.tar.gz"
      sha256 "ebfcff1278a52920e216ef2b77412a8469ab1917557659a7e326fe0439b97198"
    end
  end

  def install
    # The desired name for the executable in the user's PATH
    target_executable_name = "panther-cloud-connected-setup"
    if build.head?
      # For HEAD installs, build from source
      # Using -o to specify the output name directly
      system "go", "mod", "download"
      system "go", "build", "-o", target_executable_name, "./cmd/#{target_executable_name}/"
    else
      # For release installs, Homebrew has already downloaded the correct binary
      # based on the on_macos/on_linux and on_intel/on_arm blocks.
      # The downloaded file will have the name from the URL,
      # e.g., "panther-cloud-connected-setup-darwin-amd64".
      # Ensure the expected binary file exists in the current directory (it should have been downloaded by Homebrew)
      unless File.exist?(target_executable_name)
        odie <<~EOS
          Expected binary #{target_executable_name} not found after download.
          This means the binary for your system (#{OS.kernel_name}/#{Hardware::CPU.arch})
          might not be available in the release v#{version}, or there's an issue with the formula.
        EOS
      end
    end

    bin.install target_executable_name
  end

  test do
    # Your existing test should still work, pointing to the installed binary name
    system bin/"panther-cloud-connected-setup", "--clean"
  end
end
