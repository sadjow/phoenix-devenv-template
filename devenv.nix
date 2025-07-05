{ pkgs, ... }:

{
  languages.elixir = {
    enable = true;
    package = pkgs.beam.packages.erlang_27.elixir_1_18 or pkgs.elixir;
  };
  languages.erlang.enable = true;

  services.postgres = {
    enable = true;
    package = pkgs.postgresql_17;
    initialDatabases = [];
    initialScript = "CREATE ROLE postgres WITH LOGIN PASSWORD 'postgres' CREATEDB;";
  };

   scripts.start-postgres.exec = ''
    echo "Starting PostgreSQL service..."
    pg_ctl start -D $PGDATA -o "-p 5432" || echo "PostgreSQL may already be running or there was an error"
  '';

  git-hooks.hooks = {
    mix-format = {
      enable = true;
      name = "mix format";
      entry = "mix format --check-formatted";
      files = "\\.(ex|exs|heex)$";
    };
  };

  enterShell = ''
    echo "Elixir version: $(elixir --version)"
    echo "Erlang version: $(erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell)"
    
    # Install Hex and rebar if not already installed
    mix local.hex --force --if-missing
    mix local.rebar --force --if-missing
  '';

  enterTest = ''
    # Ensure dependencies are fetched before running tests
    if [ -f mix.exs ]; then
      echo "Fetching dependencies for test environment..."
      mix deps.get
    fi
  '';
}
