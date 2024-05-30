defmodule MoBankWeb.TransactionController do
  use MoBankWeb, :controller
  import MoBankWeb.HTTPStatusErrors, only: [bad_request: 1, bad_request: 2, not_found: 1]

  alias MoBank.PerformTransaction

  def create(conn, params) do
    case PerformTransaction.run(params) do
      {:ok, account_info} ->
        json(conn, account_info)

      {:error, :insufficient_balance} ->
        bad_request(conn)

      {:error, :account_not_found} ->
        not_found(conn)

      {:error, :unknown_error} ->
        bad_request(conn)

      {:error, error} ->
        bad_request(conn, %{error: error})
    end
  end
end
