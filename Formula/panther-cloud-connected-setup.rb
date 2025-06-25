class PantherCloudConnectedSetup < Formula
  desc "Tools for Panther deployments"
  homepage "https://github.com/panther-labs/panther-cli"
  # Specify the version of the release. This will be used in the binary URLs.
  # You will update this and the sha256 checksums for each new release.
  version "0.0.18"
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
      sha256 "d194b4edab60cf0e880090ee0c31b4840d334135b0a4ad693d4212bedc1cb83d"
    end
    on_arm do # arm64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Darwin_arm64.tar.gz"
      sha256 "a4ec8075667cb9918dcb9f6877eee8a933cc07b440b8ebd0d8832b98292a7fa9"
    end
  end

  on_linux do
    on_intel do # x86_64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Linux_x86_64.tar.gz"
      sha256 "f7c062d9b66f65e7d639aee1b14bffcb5a09888e267a06e8ddd913c9ffbf6eb9"
    end
    on_arm do # arm64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Linux_arm64.tar.gz"
      sha256 "46facb33f5d1febc7dd14d633d12b8368311e8757851a534db9b18c61d972987"
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
