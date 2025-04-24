defmodule Refmon.CacheTest do
  use ExUnit.Case

  import Refmon.Cache

  setup do
    clear_all()
    :ok
  end

  test "clear cache" do
    get_or_store("subj1", "obj1", :read, nil, fn -> :stored1 end)
    assert :stored1 == get_or_store("subj1", "obj1", :read, nil, fn -> raise RuntimeError end)
    get_or_store("subj2", "obj2", :read, nil, fn -> :stored2 end)
    assert :stored2 == get_or_store("subj2", "obj2", :read, nil, fn -> raise RuntimeError end)
    clear("subj1", "obj1")
    assert_raise Cachex.Error, fn ->
      get_or_store("subj1", "obj1", :read, nil, fn -> raise RuntimeError end)
    end
    assert :stored2 == get_or_store("subj2", "obj2", :read, nil, fn -> raise RuntimeError end)
  end

  test "clear cache subject" do
    get_or_store("subj1", "obj1", :read, nil, fn -> :stored1 end)
    assert :stored1 == get_or_store("subj1", "obj1", :read, nil, fn -> raise RuntimeError end)
    get_or_store("subj2", "obj2", :read, nil, fn -> :stored2 end)
    assert :stored2 == get_or_store("subj2", "obj2", :read, nil, fn -> raise RuntimeError end)
    assert_raise Cachex.Error, fn ->
      get_or_store("subj1", "obj1", :read, "param", fn -> raise RuntimeError end)
    end
    get_or_store("subj1", "obj1", :read, "param", fn -> :stored1 end)
    assert :stored1 == get_or_store("subj1", "obj1", :read, "param", fn -> raise RuntimeError end)
    clear_subject("subj1")
    assert_raise Cachex.Error, fn ->
      get_or_store("subj1", "obj1", :read, nil, fn -> raise RuntimeError end)
    end
    assert :stored2 == get_or_store("subj2", "obj2", :read, nil, fn -> raise RuntimeError end)
  end

  test "clear cache object" do
    get_or_store(101, 201, :read, nil, fn -> :stored1 end)
    assert :stored1 == get_or_store(101, 201, :read, nil, fn -> raise RuntimeError end)
    get_or_store(102, 202, :read, nil, fn -> :stored2 end)
    assert :stored2 == get_or_store(102, 202, :read, nil, fn -> raise RuntimeError end)
    clear_object(201)
    assert_raise Cachex.Error, fn ->
      get_or_store(101, 201, :read, nil, fn -> raise RuntimeError end)
    end
    assert :stored2 == get_or_store(102, 202, :read, nil, fn -> raise RuntimeError end)
  end

  test "clear cache all" do
    get_or_store(:subj, :obj, :read, nil, fn -> :stored end)
    assert :stored == get_or_store(:subj, :obj, :read, nil, fn -> raise RuntimeError end)
    clear_all()
    assert_raise Cachex.Error, fn ->
      get_or_store(:subj, :obj, :read, nil, fn -> raise RuntimeError end)
    end
  end

  test "store error" do
    assert_raise Protocol.UndefinedError, fn ->
      get_or_store(<<1::3, 2, 3>>, :obj, :read, nil, fn -> :stored end)
    end
  end

  test "do not cache when object id is nil" do
    get_or_store("subj1", nil, :read, nil, fn -> :stored1 end)
    assert_raise RuntimeError, fn ->
      get_or_store("subj1", nil, :read, nil, fn -> raise RuntimeError end)
    end
  end
end
