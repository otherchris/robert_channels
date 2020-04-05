defmodule RobertChannelsWeb.Router do
  use RobertChannelsWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug CORSPlug, origin: "*"
  end

  scope "/api", RobertChannelsWeb do
    pipe_through :api

    post "/create_meeting", MeetingController, :create
  end
end
