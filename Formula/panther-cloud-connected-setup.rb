class PantherCloudConnectedSetup < Formula
  # Used for programmatic updates (see update-formula.sh)
  CHECKSUMS = {
    darwin_x86_64: "9fd31a72fc80c90a481930ff8020101841fbbdd104f95047dd68594f3f3eca8f",
    darwin_arm64: "ce102d96dadb94e4c28014e23b4f85d9b6771b5cceb3b6e4bffc54bd82a94eed",
    linux_x86_64: "5e0850c8f121f12ba472277f7fa3fbc0c2f76c8a5536e24e9d12a1d5bb0cb494",
    linux_arm64: "a200bfcc55786ee00df172f25c8cceaabe7222238a02da07022d7006b96f1ebb"
  }.freeze

  desc "Tools for Panther deployments"
  homepage "https://github.com/panther-labs/panther-cli"
  # Specify the version of the release. This will be used in the binary URLs.
  # You will update this and the sha256 checksums for each new release.
  version "0.0.32"
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
      sha256 CHECKSUMS[:darwin_x86_64]
    end
    on_arm do # arm64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Darwin_arm64.tar.gz"
      sha256 CHECKSUMS[:darwin_arm64]
    end
  end

  on_linux do
    on_intel do # x86_64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Linux_x86_64.tar.gz"
      sha256 CHECKSUMS[:linux_x86_64]
    end
    on_arm do # arm64
      url "https://github.com/panther-labs/panther-cli/releases/download/v#{version}/panther-cli_Linux_arm64.tar.gz"
      sha256 CHECKSUMS[:linux_arm64]
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
