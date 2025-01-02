defmodule Swaddled.Vendor.SpotifyTest do
  use Swaddled.DataCase

  alias Swaddled.Vendor.Spotify

  describe "get_many!/2" do
    @tag :external
    test "artists" do
      artist_ids = ~w[3gMaNLQm7D9MornNILzdSl 0Je74SitssvJg1w4Ra2EK7 3JsMj0DEzyWc0VDlHuy9Bx]

      assert %{
               status: 200,
               body: %{
                 "artists" => [
                   %{
                     "genres" => ["soft rock"],
                     "name" => "Lionel Richie"
                   },
                   %{
                     "genres" => ["new wave pop", "pop rock"],
                     "name" => "4 Non Blondes"
                   },
                   %{
                     "genres" => [
                       "album rock",
                       "art rock",
                       "classic rock",
                       "glam rock",
                       "mellow gold",
                       "piano rock",
                       "progressive rock",
                       "rock",
                       "soft rock",
                       "symphonic rock"
                     ],
                     "name" => "Supertramp"
                   }
                 ]
               }
             } = Spotify.get_many!(artist_ids, "artists")
    end

    @tag :external
    test "tracks" do
      track_ids = ~w[0mHyWYXmmCB9iQyK18m3FQ 0jWgAnTrNZmOGmqgvHhZEm 5dE8s6uWRGNc1Ac7y8rULq]

      assert %{
               status: 200,
               body: %{
                 "tracks" => [
                   %{
                     "artists" => [%{"id" => "3gMaNLQm7D9MornNILzdSl", "name" => "Lionel Richie"}],
                     "name" => "Hello"
                   },
                   %{
                     "artists" => [%{"id" => "0Je74SitssvJg1w4Ra2EK7", "name" => "4 Non Blondes"}],
                     "name" => "What's Up?"
                   },
                   %{
                     "artists" => [%{"id" => "3JsMj0DEzyWc0VDlHuy9Bx", "name" => "Supertramp"}],
                     "name" => "Goodbye Stranger"
                   }
                 ]
               }
             } = Spotify.get_many!(track_ids, "tracks")
    end
  end
end
