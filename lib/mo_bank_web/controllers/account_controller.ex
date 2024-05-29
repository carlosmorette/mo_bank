defmodule MoBankWeb.AccountController do
  use MoBankWeb, :controller
  alias MoBank.ManageAccounts

  def create(conn, params) do
    case ManageAccounts.create(params) do
      {:ok, account_data} ->
	json(conn, %{numero_da_conta: account_data.id, saldo: account_data.balance})

      {:error, error} ->
	conn
	|> put_status(:bad_request)
	|> json(error)
	|> halt()
    end
  end
end
