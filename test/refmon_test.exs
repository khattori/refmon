defmodule RefmonTest do
  use ExUnit.Case

  import Refmon
  doctest Refmon


  test "invalid validate call" do
    assert_raise ArgumentError, fn ->
      defmodule InvalidCall1 do
        use Refmon
        acc = :use
        validate("obj", acc, nil)
      end
    end

    assert_raise ArgumentError, fn ->
      defmodule InvalidCall2 do
        use Refmon
        acc = :use
        validate("subj", "obj", acc, nil)
      end
    end

    assert_raise ArgumentError, fn ->
      defmodule InvalidCall2 do
        use Refmon
        acc = :use
        validate!("obj", acc, nil)
      end
    end

    assert_raise ArgumentError, fn ->
      defmodule InvalidCall2 do
        use Refmon
        acc = :use
        validate!("subj", "obj", acc, nil)
      end
    end
  end

  test "validate call in the test kernel" do
    assert :ok == Refmon.Extras.TestKernel.access()
  end
end
