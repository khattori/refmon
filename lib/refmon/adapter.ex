defmodule Refmon.Adapter do
  @moduledoc """
  Specifies the minimal API required from reference monitor policy adapters.
  """
  @callback permissions(subject :: term, object :: term, access_modes :: MapSet.t()) :: MapSet.t()
  @callback filter(
              subject :: term,
              object :: term,
              access_modes :: MapSet.t(),
              deny_or_allow :: :deny | :allow
            ) :: boolean
  @callback audit(
              subject :: term,
              object :: term,
              access_modes :: MapSet.t(),
              deny_or_allow :: :deny | :allow
            ) :: :ok

  defmacro __using__(_opts) do
    quote do
      @behaviour Refmon.Adapter
      require Logger

      def permissions(subject, object, access_modes), do: access_modes
      def filter(subject, object, access_mode, deny_or_allow), do: false

      def audit(subject, object, access_mode, deny_or_allow) do
        message = "#{deny_or_allow} #{access_mode}: subject=#{subject}, object=#{object}"
        Logger.info(message, audit_log: true)
      end

      defoverridable Refmon.Adapter
    end
  end
end
