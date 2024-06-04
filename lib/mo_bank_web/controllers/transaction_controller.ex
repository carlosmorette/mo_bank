defmodule MoBankWeb.TransactionController do
  use MoBankWeb, :controller
  import MoBankWeb.HTTPStatusErrors, only: [bad_request: 1, not_found: 1]

  alias MoBank.PerformTransaction

  def create(conn, params) do
    case PerformTransaction.run(params) do
      {:ok, account_info} ->
        conn
        |> put_status(:ok)
        |> json(account_info)

      {:error, :account_not_found} ->
        not_found(conn)

      {:error, _some_error} ->
        bad_request(conn)
    end
  end
end
