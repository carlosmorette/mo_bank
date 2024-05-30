defmodule MoBank.FormatterTest do
  use ExUnit.Case

  alias MoBank.Formatter

  describe "to_cents/1" do
    test "it should convert correctly float in cents" do
      assert 10_30 = Formatter.to_cents(10.30)
      assert 5_99 = Formatter.to_cents(5.99)
      assert 3_00 = Formatter.to_cents(3.00)
    end

    test "it should raise a guard error when value is not float" do
      assert_raise FunctionClauseError, fn ->
        Formatter.to_cents(5600)
      end
    end
  end

  describe "to_float/1" do
    test "it should convert correctly integer to float" do
      assert 56.00 = Formatter.to_float(5600)
      assert 1.00 = Formatter.to_float(100)
      assert 0.09 = Formatter.to_float(9)
    end

    test "it should raise a guard error when value is not integer" do
      assert_raise FunctionClauseError, fn ->
        Formatter.to_float(13.81)
      end
    end
  end
end
