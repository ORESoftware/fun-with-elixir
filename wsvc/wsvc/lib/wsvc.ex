defmodule Wsvc.Application do
  @moduledoc """
  Documentation for `Wsvc`.
  """

  use Application

  def start(_type, _args) do
    children = [
      # List all child processes to be supervised

      # Start HTTP server
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Wsvc.Endpoint,
        options: Application.get_env(:wsvc, :endPoint)[:port]
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [
      strategy: :one_for_one,
      name: Wsvc.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

  def getWeatherData(lat, lon) when is_float(lat) and is_float(lon) do
    case HTTPoison.get(
           "https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&appid=88b05b8a3b55dff5696740036a075355&units=metric"
         ) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, data} = body |> Poison.decode()
        data

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts("Not found :(")

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect(reason)
    end
  end
end
