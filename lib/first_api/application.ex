defmodule FirstApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: FirstApi.Worker.start_link(arg)
      # {FirstApi.Worker, arg}
      {
        Plug.Cowboy,
        scheme: :http,
        plug: FirstApi.Router,
        options: [port: Application.get_env(:first_api, :port)]
      },
      {
        MyXQL,
        name: :myxql,
        hostname: Application.get_env(:first_api, :mysql_host),
        username: Application.get_env(:first_api, :mysql_username),
        password: Application.get_env(:first_api, :mysql_password),
        database: Application.get_env(:first_api, :mysql_database)
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: FirstApi.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
