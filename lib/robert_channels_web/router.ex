defmodule RobertChannelsWeb.Router do
  use RobertChannelsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", RobertChannelsWeb do
    pipe_through :api
  end
end
