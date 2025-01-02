defmodule Swaddled.Vendor.Spotify do
  @moduledoc """
  A quick and dirty wrapper for the Spotify Web API. Specifically for this app,
  we only care about using this data to get genre information. Be sure to set
  `SPOTIFY_CLIENT_ID` and `SPOTIFY_CLIENT_SECRET` in your env vars!
  """

  def get_many!(ids, resource) when is_list(ids) and resource in ~w[artists tracks] do
    Req.get!(req(), url: "/#{resource}?ids=#{Enum.join(ids, ",")}")
  end

  defp req do
    Req.new(
      base_url: "https://api.spotify.com/v1",
      auth: {:bearer, access_token()}
    )
  end

  defp access_token do
    client_id = System.get_env("SPOTIFY_CLIENT_ID")
    client_secret = System.get_env("SPOTIFY_CLIENT_SECRET")
    if !client_id || !client_secret, do: raise("Missing Spotify env vars")

    Req.post!("https://accounts.spotify.com/api/token",
      form: %{
        grant_type: "client_credentials",
        client_id: client_id,
        client_secret: client_secret
      }
    ).body["access_token"]
  end
end
