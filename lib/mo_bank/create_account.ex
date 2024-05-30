defmodule MoBank.CreateAccount do
  use Params
  alias MoBank.Entities.Account
  alias MoBank.Formatter

  defparams(
    create_account_params(%{
      numero_da_conta!: :integer,
      saldo!: :float
    })
  )

  def run(params) do
    with {:ok, params} <- validate_and_format_external_params(params),
         {:ok, %Account{} = account} <- Account.create(params) do
      {:ok, format_to_external(account)}
    end
  end

  def validate_and_format_external_params(data) do
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

  def format_to_external(%Account{} = acc) do
    %{
      numero_da_conta: acc.account_number,
      saldo: Formatter.to_float(acc.balance)
    }
  end
end
