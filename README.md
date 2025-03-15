# Elixir Devenv Template

A minimal and reproducible development environment for Elixir and Erlang projects using [devenv](https://devenv.sh/) and Nix.

## Features

- Always uses the latest stable Elixir (currently 1.18.3) and Erlang/OTP (currently 27.3)
- Automatic environment activation with direnv (optional but recommended)
- Zero system-wide installations required (except Nix itself)
- Consistent developer experience across all platforms (macOS, Linux, WSL)
- CI integration with GitHub Actions
- Automated dependency updates with Dependabot

## Prerequisites

- [Nix](https://nixos.org/download.html) package manager
- [direnv](https://direnv.net/docs/installation.html) for automatic environment activation (optional but recommended)

## Getting Started

1. Click "Use this template" to create a new repository based on this template
2. Clone your new repository
3. Navigate to the project directory
4. Run `direnv allow` to activate the environment (if using direnv), or run `devenv shell` manually

```bash
# After cloning your new repository:
cd your-project-name

# If using direnv (recommended):
direnv allow

# Or manually enter the environment:
devenv shell

# You should see output showing your Elixir and Erlang versions
```

## How It Works

This template uses:

- `devenv.nix` - Defines the development environment with Elixir and Erlang
- `devenv.yaml` - Configures devenv to use nixpkgs-unstable for the latest packages
- `.envrc` - Configures direnv to use devenv (optional, but provides automatic activation)

### Why nixpkgs-unstable?

By default, devenv uses `github:cachix/devenv-nixpkgs/rolling` as its nixpkgs source. However, this template intentionally uses `github:NixOS/nixpkgs/nixpkgs-unstable` for several reasons:

1. **Latest Elixir versions:** The nixpkgs-unstable channel typically includes the most recent versions of Elixir and Erlang soon after they're released. For example, Elixir 1.18.3 was available in nixpkgs-unstable before it appeared in the default devenv nixpkgs.

2. **Broader package selection:** Access to the complete set of packages in the main nixpkgs repository, which may be useful when adding dependencies to your project.

3. **Community updates:** The main nixpkgs repository receives more frequent updates for language-specific packages from the broader Nix community.

This approach prioritizes having the latest language features over the potential stability benefits of the default channel. For most Elixir development, this trade-off is worthwhile as it provides access to the newest language capabilities.

#### Alternative Approach

If you encounter issues with our direct method (replacing the nixpkgs source in devenv.yaml), you can follow the [official devenv approach](https://devenv.sh/common-patterns/#getting-a-recent-version-of-a-package-from-nixpkgs-unstable) for using packages from nixpkgs-unstable:

1. Keep the default nixpkgs source and add nixpkgs-unstable as an additional input in `devenv.yaml`:

   ```yaml
   inputs:
     nixpkgs:
       url: github:cachix/devenv-nixpkgs/rolling
     nixpkgs-unstable:
       url: github:nixos/nixpkgs/nixpkgs-unstable
   ```

2. Use the unstable package in `devenv.nix`:
   ```nix
   { pkgs, inputs, ... }:
   let
     pkgs-unstable = import inputs.nixpkgs-unstable { system = pkgs.stdenv.system; };
   in
   {
     languages.elixir = {
       enable = true;
       package = pkgs-unstable.beam.packages.erlang_27.elixir;
     };
     languages.erlang.enable = true;
   }
   ```

This method keeps the stability benefits of the default devenv nixpkgs for most packages while still allowing specific access to newer versions from unstable when needed.

For more information:

- [Devenv documentation on using nixpkgs-unstable](https://devenv.sh/common-patterns/#getting-a-recent-version-of-a-package-from-nixpkgs-unstable)
- [Discussion about package versioning in Nix](https://github.com/NixOS/nixpkgs/issues/93327)
- [NixOS search for Elixir packages](https://search.nixos.org/packages?channel=unstable&query=elixir)

## CI Setup

This template includes GitHub Actions workflows for continuous integration:

- **CI workflow**: Automatically tests that the development environment builds correctly on every push and pull request
  - Tests on both Ubuntu and macOS to ensure cross-platform compatibility
- **Format checking**: Verifies that Nix and YAML files adhere to consistent formatting guidelines
- **Documentation validation**:
  - Checks for broken links in markdown files
  - Validates markdown for common style and formatting issues
- **Dependency updates**: A scheduled workflow that automatically updates Nix dependencies and creates a pull request with the changes
- **Dependabot**: Keeps GitHub Actions dependencies up-to-date with weekly checks

These workflows ensure that your development environment remains stable, well-formatted, and up-to-date with minimal manual intervention.

## Customizing

### Adding dependencies

To add additional packages to your environment, modify the `devenv.nix` file:

```nix
{ pkgs, ... }:

{
  # Add packages you need in your environment
  packages = [
    pkgs.postgresql
    # Add more packages here
  ];

  languages.elixir = {
    enable = true;
    package = pkgs.beam.packages.erlang_27.elixir_1_18 or pkgs.elixir;
  };
  languages.erlang.enable = true;

  # Enable PostgreSQL service
  # services.postgres.enable = true;

  enterShell = ''
    echo "Elixir version: $(elixir --version)"
    echo "Erlang version: $(erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell)"
  '';
}
```

### Using a specific Elixir version

If you need a specific version of Elixir, modify the package line in `devenv.nix`:

```nix
languages.elixir = {
  enable = true;
  package = pkgs.beam.packages.erlang_27.elixir_1_17;
};
```

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

[MIT](LICENSE)
