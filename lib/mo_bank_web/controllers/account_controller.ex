defmodule MoBankWeb.AccountController do
  use MoBankWeb, :controller
  import MoBankWeb.HTTPStatusErrors, only: [bad_request: 2, not_found: 1]
  alias MoBank.{CreateAccount, FindAccount}

  def create(conn, params) do
    params = %{
      numero_conta: params["numero_conta"],
      saldo: params["saldo"]
    }

    case CreateAccount.run(params) do
      {:ok, account_info} ->
        conn
        |> put_status(:ok)
        |> json(account_info)

      {:error, error} ->
        bad_request(conn, %{error: error})
    end
  end

  def get(conn, _params) do
    if account_info = FindAccount.run(account_number: conn.query_params["numero_conta"]) do
      conn
      |> put_status(:ok)
      |> json(account_info)
    else
      not_found(conn)
    end
  end
end
