defmodule Refmon.Cache do
  alias Refmon.Identifiable


  def get_or_store(subj, obj, acc, param, store_fn) do
    subj_id = Identifiable.to_identifier(subj)
    obj_id = Identifiable.to_identifier(obj)
    if is_nil(obj_id) do
      #
      # ID が nil の場合はキャッシュしない
      #
      store_fn.()
    else
      #
      # 以下のようなデータ構造でキャッシュに格納される
      #
      # { <subj_id>, <obj_id> } |--> %{ {<acc>, <param>} |--> <value> }
      #
      Cachex.get_and_update!(__MODULE__, {subj_id, obj_id}, fn val ->
        val = val || %{}
        if Map.has_key?(val, {acc, param}) do
          {:commit, val}
        else
          {:commit, Map.put(val, {acc, param}, store_fn.())}
        end
      end)[{acc, param}]
    end
  end

  def clear(subj, obj) do
    subj_id = Identifiable.to_identifier(subj)
    obj_id = Identifiable.to_identifier(obj)
    {:ok, true} = Cachex.del(__MODULE__, {subj_id, obj_id})
    :ok
  end

  def clear_subject(subj) do
    subj_id = Identifiable.to_identifier(subj)
    query = Cachex.Query.create({:==, {:element, 1, :key}, subj_id}, :key)
    {:ok, result} = Cachex.stream(__MODULE__, query)
    for key <- result do
      {:ok, true} = Cachex.del(__MODULE__, key)
    end
    :ok
  end

  def clear_object(obj) do
    obj_id = Identifiable.to_identifier(obj)
    query = Cachex.Query.create({:==, {:element, 2, :key}, obj_id}, :key)
    {:ok, result} = Cachex.stream(__MODULE__, query)
    for key <- result do
      {:ok, true} = Cachex.del(__MODULE__, key)
    end
    :ok
  end

  def clear_all() do
    Cachex.clear(__MODULE__)
  end
end
