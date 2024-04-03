defmodule ShowmakerBackendWeb.Router do
  use ShowmakerBackendWeb, :router

  import ShowmakerBackendWeb.Accounts.AccountAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ShowmakerBackendWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_protected do
    plug :require_authentication
  end

  scope "/", ShowmakerBackendWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/api", ShowmakerBackendWeb do
    pipe_through :api

    get "/health_check", HealthCheckController, :index
  end

  scope "/api/accounts", ShowmakerBackendWeb.Accounts do
    pipe_through :api

    post "/register", AccountRegistrationController, :create
    post "/confirm", AccountConfirmationController, :create
    post "/confirm/:confirm_token", AccountConfirmationController, :update
    post "/sign_in", AccountSessionController, :create
    post "/reset_password", AccountResetPasswordController, :create
    put "/reset_password/:reset_token", AccountResetPasswordController, :update
  end

  scope "/api/accounts", ShowmakerBackendWeb.Accounts do
    pipe_through [:api, :api_protected]

    delete "/sign_out", AccountSessionController, :delete
    put "/settings", AccountSettingsController, :update
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShowmakerBackendWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:showmaker_backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ShowmakerBackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
