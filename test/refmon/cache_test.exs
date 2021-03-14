defmodule Refmon.CacheTest do
  use ExUnit.Case

  import Refmon.Cache

  setup do
    clear_all()
    :ok
  end

  test "clear cache" do
    get_or_store("subj1", "obj1", fn -> :stored1 end)
    assert :stored1 == get_or_store("subj1", "obj1", fn -> throw(:cache_error) end)
    get_or_store("subj2", "obj2", fn -> :stored2 end)
    assert :stored2 == get_or_store("subj2", "obj2", fn -> throw(:cache_error) end)
    clear("subj1", "obj1")
    assert catch_throw(get_or_store("subj1", "obj1", fn -> throw(:called) end)) == :called
    assert :stored2 == get_or_store("subj2", "obj2", fn -> throw(:cache_error) end)
  end

  test "clear cache subject" do
    get_or_store("subj1", "obj1", fn -> :stored1 end)
    assert :stored1 == get_or_store("subj1", "obj1", fn -> throw(:cache_error) end)
    get_or_store("subj2", "obj2", fn -> :stored2 end)
    assert :stored2 == get_or_store("subj2", "obj2", fn -> throw(:cache_error) end)
    clear_subject("subj1")
    assert catch_throw(get_or_store("subj1", "obj1", fn -> throw(:called) end)) == :called
    assert :stored2 == get_or_store("subj2", "obj2", fn -> throw(:cache_error) end)
  end

  test "clear cache object" do
    get_or_store(101, 201, fn -> :stored1 end)
    assert :stored1 == get_or_store(101, 201, fn -> throw(:cache_error) end)
    get_or_store(102, 202, fn -> :stored2 end)
    assert :stored2 == get_or_store(102, 202, fn -> throw(:cache_error) end)
    clear_object(201)
    assert catch_throw(get_or_store(101, 201, fn -> throw(:called) end)) == :called
    assert :stored2 == get_or_store(102, 202, fn -> throw(:cache_error) end)
  end

  test "clear cache all" do
    get_or_store(:subj, :obj, fn -> :stored end)
    assert :stored == get_or_store(:subj, :obj, fn -> throw(:cache_error) end)
    clear_all()
    assert catch_throw(get_or_store(:subj, :obj, fn -> throw(:called) end)) == :called
  end

  test "store error" do
    assert_raise Protocol.UndefinedError, fn ->
      get_or_store(<<1::3, 2, 3>>, :obj, fn -> :stored end)
    end
  end
end
