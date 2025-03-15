{ pkgs, ... }:

{
  languages.elixir = {
    enable = true;
    package = pkgs.beam.packages.erlang_27.elixir_1_18 or pkgs.elixir;
  };
  languages.erlang.enable = true;

  enterShell = ''
    echo "Elixir version: $(elixir --version)"
    echo "Erlang version: $(erl -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().' -noshell)"
  '';
}
