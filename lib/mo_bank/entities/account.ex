defmodule MoBank.Entities.Account do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias MoBank.Repo

  schema "accounts" do
    ## TODO: agora vai buscar por account_number
    field :account_number, :string
    field :balance, :integer

    timestamps()
  end

  def create_changeset(account, attrs) do
    account
    |> cast(attrs, [:balance, :id])
    |> validate_required([:balance, :id])
  end

  def update_changeset(account, attrs) do
    cast(account, attrs, [:balance])
  end

  def create(data) do
    %__MODULE__{}
    |> create_changeset(data)
    |> Repo.insert()
  end

  def find_for_update(id: id) do
    query =
      from a in __MODULE__,
        where: a.id == ^id,
        lock: "FOR UPDATE"

    Repo.one(query)
  end

  def decrease_balance(%__MODULE__{} = account, amount: amount) do
    account
    |> update_changeset(%{balance: account.balance - amount})
    |> Repo.update()
  end

  def find(account_number: account_number) do
    Repo.get_by(__MODULE__, account_number: account_number)
  end
end
