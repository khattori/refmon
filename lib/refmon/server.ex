defmodule Refmon.Server do
  use GenServer
  alias Refmon.Cache

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    otp_app = Keyword.get(opts, :otp_app)
    this_app = Application.get_application(__MODULE__)
    apps = Application.spec(otp_app, :applications) || []
    apps = [otp_app | apps]
    access_modes =
      Enum.reduce(apps, MapSet.new(), fn app, acc ->
        if app == this_app or this_app in Application.spec(app, :applications) do
          register_access_modes(app) |> MapSet.union(acc)
        else
          acc
        end
      end)

    {:ok, %{adapter: Keyword.get(opts, :adapter), access_modes: access_modes}}
  end

  defp register_access_modes(app) when is_atom(app) do
    app_mods = Application.spec(app, :modules) || []
    for mod <- app_mods do
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

  def adapter() do
    GenServer.call(__MODULE__, :adapter)
  end

  def access_modes() do
    GenServer.call(__MODULE__, :access_modes)
  end

  # subjがnilの場合、システムアクセスのため常に許可し、監査もパスする
  def validate(nil, _obj, _acc, _param), do: :allow
  def validate(subj, obj, acc, param) do
    # 許可リストに含まれていれば ok
    permission(subj, obj, acc, param)
    |> audit(subj, obj, acc, param)
  end

  defp permission(subj, obj, acc, param) do
    Cache.get_or_store(subj, obj, acc, param,
      fn ->
        GenServer.call(__MODULE__, {:permission, subj, obj, acc, param})
      end
    )
  end

  defp audit(deny_or_permit, subj, obj, acc, param) do
    GenServer.call(__MODULE__, {:audit, deny_or_permit, subj, obj, acc, param})
    deny_or_permit
  end

  def handle_call({:permission, subj, obj, acc, param}, _from, %{adapter: adapter} = state) do
    perm = adapter.permission(subj, obj, acc, param)
    {:reply, perm, state}
  end

  def handle_call({:audit, deny_or_permit, subj, obj, acc, param}, _from, %{adapter: adapter} = state) do
    if not adapter.filter(subj, obj, acc, param, deny_or_permit) do
      adapter.audit(subj, obj, acc, param, deny_or_permit)
    end
    {:reply, :ok, state}
  end

  def handle_call(:adapter, _from, %{adapter: adapter} = state) do
    {:reply, adapter, state}
  end

  def handle_call(:access_modes, _from, %{access_modes: modes} = state) do
    {:reply, modes, state}
  end
end
