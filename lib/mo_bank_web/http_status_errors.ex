defmodule MoBankWeb.HTTPStatusErrors do
  @moduledoc """
  Módulo responsável por padronizar as respostas de erro HTTP da API.

  Fornece funções auxiliares para retornar respostas de erro comuns
  como bad_request (400) e not_found (404) de forma consistente.
  """
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
