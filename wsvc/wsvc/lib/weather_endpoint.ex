defmodule Wsvc.Endpoint do
  @moduledoc """

  Weather endpoints :
  - /get-weather : get weather of given place by submitting the lat and lon coordinates (POST)
  """
  use Plug.Router

  # This module is a Plug, that also implements it's own plug pipeline, below:

  # Using Plug.Logger for logging request information
  plug(Plug.Logger)

  # responsible for matching routes
  plug(:match)

  # Using Poison for JSON decoding
  # Note, order of plugs is important, by placing this _after_ the 'match' plug,
  # we will only parse the request AFTER there is a route match.
  plug(Plug.Parsers,
    parsers: [:json],
    json_decoder: Poison
  )

  # responsible for dispatching responses
  plug(:dispatch)

  # A simple route to test that the server is up
  # Note, all routes must return a connection as per the Plug spec.
  post "/get-weather" do
    {status, body} =
      case conn.body_params do
        %{"lat" => lat, "lon" => lon} ->
          {200,
           Poison.encode!(%{
             "temperature(degrees celcius)" =>
               Wsvc.Application.getWeatherData(lat, lon) |> Map.get("main") |> Map.get("temp")
           })}

        _ ->
          {422, "missing_latlon coordinates"}
      end

    IO.puts("#{body} is ")
    send_resp(conn, status, body)
  end

  # A catchall route, 'match' will match no matter the request method,
  # so a response is always returned, even if there is no route to match.
  match _ do
    send_resp(conn, 404, "The page does not exist")
  end
end
