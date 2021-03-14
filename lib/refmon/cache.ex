defmodule Refmon.Cache do
  alias Refmon.Identifiable

  def get_or_store(subj, obj, store_fn) do
    subj_id = Identifiable.to_identifier(subj)
    obj_id = Identifiable.to_identifier(obj)
    ConCache.dirty_get_or_store(__MODULE__, {subj_id, obj_id}, store_fn)
  end

  def clear(subj, obj) do
    subj_id = Identifiable.to_identifier(subj)
    obj_id = Identifiable.to_identifier(obj)

    ConCache.ets(__MODULE__)
    |> :ets.match_delete({{subj_id, obj_id}, :_})
  end

  def clear_subject(subj) do
    subj_id = Identifiable.to_identifier(subj)

    ConCache.ets(__MODULE__)
    |> :ets.match_delete({{subj_id, :_}, :_})
  end

  def clear_object(obj) do
    obj_id = Identifiable.to_identifier(obj)

    ConCache.ets(__MODULE__)
    |> :ets.match_delete({{:_, obj_id}, :_})
  end

  def clear_all() do
    ConCache.ets(__MODULE__)
    |> :ets.match_delete(:_)
  end
end
