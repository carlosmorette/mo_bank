defmodule MoBank.Entities.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias MoBank.Repo

  schema "accounts" do
    field :account_number, :string
    field :balance, :integer

    timestamps()
  end

  def create_changeset(account, attrs) do
    account
    |> cast(attrs, [:balance, :account_number])
    |> validate_required([:balance, :account_number])
    |> unique_constraint(:account_number)
  end

  def update_changeset(account, attrs) do
    cast(account, attrs, [:balance])
  end

  def create(data) do
    %__MODULE__{}
    |> create_changeset(data)
    |> Repo.insert()
  end

  def query_find_for_update(account_number: account_number) do
    query =
      from a in __MODULE__,
        where: a.id == ^account_number,
        lock: "FOR UPDATE"
  end

  def decrease_balance_changeset(%__MODULE__{} = account, amount: amount) do
    update_changeset(account, %{balance: account.balance - amount})
  end

  def find(account_number: account_number) do
    Repo.get_by(__MODULE__, account_number: account_number)
  end
end
