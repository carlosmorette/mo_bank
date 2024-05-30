defmodule MoBank.Entities.TransactionType do
  use Ecto.Schema
  import Ecto.Changeset

  alias MoBank.Repo

  @type t :: %__MODULE__{}

  schema "transaction_types" do
    field :type, Ecto.Enum, values: [:debit_card, :credit_card, :pix]
    field :percentage_fee, :integer

    timestamps()
  end

  def find(type: type) do
    Repo.get_by(__MODULE__, type: type)
  end

  ## used only by admins
  def create(type: type, percentage_fee: percentage_fee) do
    Repo.insert(%__MODULE__{type: type, percentage_fee: percentage_fee})
  end
end
