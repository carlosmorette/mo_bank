defmodule MoBankWeb.HTTPStatusErrors do
  import Plug.Conn, only: [put_status: 2, halt: 1]
  import Phoenix.Controller, only: [json: 2]

  def bad_request(conn, details \\ %{}), do: return_error(conn, :bad_request, details)
  def not_found(conn, details \\ %{}), do: return_error(conn, :not_found, details)

  defp return_error(conn, http_error, details) do
    conn
    |> put_status(http_error)
    |> json(details)
    |> halt()
  end
end
