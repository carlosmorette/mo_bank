defmodule MoBank.ManageAccounts do
  use Params
  alias MoBank.Entities.Account
  alias MoBank.Formatter

  defparams(
    create_account_params(%{
      numero_da_conta!: :integer,
      saldo!: :float
    })
  )

  def create(params) do
    with {:ok, params} <- validate_external_params(params),
         {:ok, %Account{id: id, balance: balance}} <- Account.create(params) do
      {:ok, %{id: id, balance: Formatter.to_float(balance)}}
    end
  end

  def validate_external_params(data) do
    case create_account_params(data) do
      %Ecto.Changeset{valid?: true} = changeset ->
        {:ok, format_to_database(changeset)}

      changeset ->
        {:error, Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)}
    end
  end

  def format_to_database(%Ecto.Changeset{} = changeset) do
    %{
      id: changeset.changes.numero_da_conta,
      balance: Formatter.to_cents(changeset.changes.numero_da_conta)
    }
  end
end
