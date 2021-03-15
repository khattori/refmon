defmodule Refmon.Server do
  use GenServer
  alias Refmon.Cache

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    otp_app = Keyword.get(opts, :otp_app)
    apps = [otp_app | otp_app |> Application.spec(:applications)]

    access_modes =
      Enum.reduce(apps, MapSet.new(), fn app, acc ->
        register_access_modes(app) |> MapSet.union(acc)
      end)

    {:ok, %{adapter: Keyword.get(opts, :adapter), access_modes: access_modes}}
  end

  defp register_access_modes(app) when is_atom(app) do
    for mod <- Application.spec(app, :modules) do
      try do
        for values <- Keyword.get_values(mod.__info__(:attributes), :registered_access_modes) do
          values
        end
        |> List.flatten()
      rescue
        UndefinedFunctionError -> []
        FunctionClauseError -> []
      end
    end
    |> List.flatten()
    |> MapSet.new()
  end

  def access_modes() do
    GenServer.call(__MODULE__, :access_modes)
  end

  def validate(subj, obj, acc) do
    # subject が nil もしくは 許可リストに含まれていれば ok
    if is_nil(subj) || acc in permissions(subj, obj) do
      :allow
    else
      :deny
    end
    |> audit(subj, obj, acc)
  end

  defp permissions(subj, obj) do
    Cache.get_or_store(subj, obj, fn ->
      GenServer.call(__MODULE__, {:permissions, subj, obj})
    end)
  end

  defp audit(deny_or_permit, subj, obj, acc) do
    GenServer.call(__MODULE__, {:audit, deny_or_permit, subj, obj, acc})
    deny_or_permit
  end

  def handle_call({:permissions, subj, obj}, _from, %{adapter: adapter} = state) do
    perms = adapter.permissions(subj, obj, state.access_modes)
    {:reply, perms, state}
  end

  def handle_call({:audit, deny_or_permit, subj, obj, acc}, _from, %{adapter: adapter} = state) do
    if not adapter.filter(subj, obj, acc, deny_or_permit) do
      adapter.audit(subj, obj, acc, deny_or_permit)
    end

    {:reply, :ok, state}
  end

  def handle_call(:access_modes, _from, %{access_modes: modes} = state) do
    {:reply, modes, state}
  end
end
