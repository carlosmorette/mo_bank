defmodule MoBankWeb.ProbeController do
  use MoBankWeb, :controller

  def health(conn, _params) do
    {:ok, host} = :inet.gethostname()
    json(conn, %{status: "ok", service: "mo_bank", host: to_string(host)})
  end

  def ready(conn, _params) do
    MoBank.Repo.query!("SELECT 1")

    json(conn, %{status: "ok", service: "mo_bank"})
  end
end
