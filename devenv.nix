{ pkgs, ... }:

{
  packages = [
    pkgs.pre-commit
    pkgs.nodejs_20  # For Phoenix assets
    pkgs.postgresql # For Phoenix database
  ];

  languages.elixir = {
    enable = true;
    package = pkgs.beam.packages.erlang_27.elixir_1_18 or pkgs.elixir;
  };
  languages.erlang.enable = true;

  # Enable PostgreSQL service for Phoenix
  services.postgres = {
    enable = true;
    package = pkgs.postgresql_16;
    initialDatabases = [ { name = "phoenix_devenv_dev"; } ];
    initialScript = "CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' CREATEDB;";
  };

  scripts.check-postgres.exec = ''
    if pg_isready -q -d phoenix_devenv_dev -U postgres -h localhost; then
      echo "PostgreSQL is running and accepting connections on database 'phoenix_devenv_dev' with user 'postgres'."
      exit 0
    else
      echo "PostgreSQL is not ready or not accepting connections."
      exit 1
    fi
  '';

  scripts.start-postgres.exec = ''
    echo "Starting PostgreSQL service..."
    pg_ctl start -D $PGDATA -o "-p 5432" || echo "PostgreSQL may already be running or there was an error"
  '';

  pre-commit = {
    hooks = {
      markdownlint = {
        enable = true;
        # See more at configuration options: https://github.com/DavidAnson/markdownlint/blob/main/schema/.markdownlint.jsonc
        settings.configuration = {
          default = true;
          MD013 = false;
          MD024 = false;
          MD033 = false;
        };
      };
    };
  };

  enterShell = ''
    echo "Elixir version: $(elixir --version)"
    echo "Erlang version: $(erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell)"
    echo "Node.js version: $(node --version)"
    echo "PostgreSQL version: $(psql --version)"

    # Check if Phoenix CLI is installed
    if ! mix archive | grep -q "phx_new"; then
      echo "Phoenix CLI not installed. Installing now..."
      mix archive.install hex phx_new --force
    else
      echo "Phoenix CLI is installed."
    fi
  '';

  enterTest = ''
    mix do deps.get, ecto.create, ecto.migrate, test
  '';
}
