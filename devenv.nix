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
    initialDatabases = [ { name = "phoenix_dev"; } { name = "phoenix_test"; } ];
    initialScript = "CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' CREATEDB;";
  };

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
}
