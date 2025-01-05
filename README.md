# Swaddled

Missed out on your Spotify Wrapped? Or want to see your top artists and songs
for the entire year? What about compared to previous years? Do it all with
Swaddled!

<p align="center">
 <img src="https://github.com/user-attachments/assets/e524c8d0-a597-431e-a307-659d5191fee4" />
</p>

## Why Swaddled?

This is a project born out of hate. Let's be honest: Spotify's 2024 Wrapped
sucked. Personally, I missed the "top genres" categories they had in previous
years. I mean, what the heck was that AI garbage? "Academic Beats Edm" means
nothing to me (yes, that really was on my Wrapped...). So I decided to make my
own Wrapped while I played around with [Elixir
v1.18](https://elixir-lang.org/blog/2024/12/19/elixir-v1-18-0-released/).

# Getting Started

This project isn't hosted anywhere, so if you want to play around with it,
you'll need to run it locally with the instructions below.

## Artist and Track Data

Before we began, you'll need to download a zip file of your extended history
from Spotify to populate artist and track data. Requesting this file can take up
to 30 days. In the meantime, you can use the `my_spotify_data.zip` file in `test`
folder to play around.

### Downloading your extended streaming history

1. In the web browser, [log in to your Spotify account](https://accounts.spotify.com/).

1. Click your avatar in the top-right corner and click "Account".

1. Scroll down to the "Security and privacy" section and click "Account privacy".

1. Scroll to the bottom to where it says "Extended streaming history". Click the
checkbox next to "Select Extended streaming history". Uncheck any other boxes.
Click the "Request data" button.

1. In the next 30 days, you'll receive an email to download your own zip file.
Then come back and enjoy this app!

## Genre Data

Unfortunately, the extended streaming history does not include genre
information. The genres is poorly designed in Spotify, too, as I mention in
`Swaddled.Genres`. However, I was determined to get this data for myself.

If you would like to see genres data, you'll need to [create a Spotify
app](https://developer.spotify.com/documentation/web-api/concepts/apps) to get
your `Client ID` and `Client Secret` credentials.

## Installing and Running

1. Clone the repo:
   ```
   git clone https://github.com/davenguyen/swaddled
   ```

1. Run the following steps (assuming Elixir 1.18 is installed):
   ```
   cd swaddled
   mix deps.get
   mix ecto.setup
   mix phx.server
   ```

1. Visit [http://localhost:4000](http://localhost:4000) in your browser.

1. Import your Spotify data. Upload your own zip file or use the
`my_spotify_data.zip` file in the test folder.

1. If you have your Spotify `client ID` and `client secret` handy, you can
   import genre data now.

1. Enjoy your Swaddled!
