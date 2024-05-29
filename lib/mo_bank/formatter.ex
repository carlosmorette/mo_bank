defmodule MoBank.Formatter do
  @spec to_cents(float) :: integer
  def to_cents(value) when is_float(value) do
    round(value * 100)
  end

  @spec to_float(integer) :: float
  def to_float(cents) when is_integer(cents) do
    cents / 100
  end
end
