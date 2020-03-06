defmodule ClientAppWeb.Presence do
  use Phoenix.Presence, otp_app: :client_app, pubsub_server: ClientApp.PubSub
end
