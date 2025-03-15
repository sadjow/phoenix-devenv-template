# Elixir Devenv Template

A minimal and reproducible development environment for Elixir and Erlang projects using [devenv](https://devenv.sh/) and Nix.

## Features

- Always uses the latest stable Elixir (currently 1.18.3) and Erlang/OTP (currently 27.3)
- Automatic environment activation with direnv (optional but recommended)
- Zero system-wide installations required (except Nix itself)
- Consistent developer experience across all platforms (macOS, Linux, WSL)

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
