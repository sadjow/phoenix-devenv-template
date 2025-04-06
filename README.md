# Phoenix Devenv Reference Implementation

A reference implementation and development environment for Phoenix Framework projects using [devenv](https://devenv.sh/) and Nix. This project demonstrates how to use devenv to create a reproducible development environment for Phoenix applications.

## Features

- Latest Phoenix Framework with LiveView support
- Latest stable Elixir (currently 1.18.3) and Erlang/OTP (currently 27.3)
- PostgreSQL database pre-configured
- Node.js for asset compilation
- Automatic environment activation with direnv
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
```

## Using the Phoenix Application

This repository includes a pre-generated Phoenix application as a reference.

To start the Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Creating a New Phoenix Project

You can use this template as a starting point for new Phoenix projects. If you want to create a completely new Phoenix application:

### Standard Phoenix Application

```bash
mix phx.new app_name
```

### Phoenix API-only Application

```bash
mix phx.new app_name --no-html --no-assets
```

### Phoenix Application with LiveView

```bash
mix phx.new app_name --live
```

## PostgreSQL Configuration

The PostgreSQL database is pre-configured with the following settings:

- Username: postgres
- Password: postgres
- Database: phoenix_dev (for development)
- Database: phoenix_test (for testing)

To configure your Phoenix application to use these settings, update the `config/dev.exs` and `config/test.exs` files:

```elixir
# Configure your database
config :your_app, YourApp.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "phoenix_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
```

## How It Works

This template uses:

- `devenv.nix` - Defines the development environment with Elixir, Erlang, PostgreSQL, and Node.js
- `devenv.yaml` - Configures devenv to use nixpkgs-unstable for the latest packages
- `.envrc` - Configures direnv to use devenv (optional, but provides automatic activation)

This reference implementation includes all dependencies required for Phoenix development, including:

- PostgreSQL database for data storage
- Node.js for asset compilation
- Phoenix CLI for generating new projects

## Customizing

### Adding dependencies

To add additional packages to your environment, modify the `devenv.nix` file:

```nix
{ pkgs, ... }:

{
  packages = [
    pkgs.pre-commit
    pkgs.nodejs_20
    pkgs.postgresql
    # Add more packages here
  ];

  languages.elixir = {
    enable = true;
    package = pkgs.beam.packages.erlang_27.elixir_1_18 or pkgs.elixir;
  };
  languages.erlang.enable = true;

  # Enable PostgreSQL service
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    initialDatabases = [ { name = "phoenix_dev"; } { name = "phoenix_test"; } ];
    initialScript = "CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' CREATEDB;";
  };

  # Other configuration...
}
```

## Learn More About Phoenix

- Official website: [https://www.phoenixframework.org/](https://www.phoenixframework.org/)
- Guides: [https://hexdocs.pm/phoenix/overview.html](https://hexdocs.pm/phoenix/overview.html)
- Docs: [https://hexdocs.pm/phoenix](https://hexdocs.pm/phoenix)
- Forum: [https://elixirforum.com/c/phoenix-forum](https://elixirforum.com/c/phoenix-forum)
- Source: [https://github.com/phoenixframework/phoenix](https://github.com/phoenixframework/phoenix)

## Deploying Phoenix Applications

This template focuses on the development environment. For production deployments, consider:

- [Fly.io](https://fly.io/docs/elixir/getting-started/) - Easy deployment for Phoenix apps
- [Gigalixir](https://gigalixir.com/) - PaaS designed for Elixir
- [Render](https://render.com/docs/deploy-phoenix) - Cloud hosting with PostgreSQL support
- [Releases with Elixir](https://hexdocs.pm/phoenix/releases.html) - For custom deployment options

## Contributing

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

[MIT](LICENSE)
