defmodule Refmon.Adapter do
  @moduledoc """
  Specifies the minimal API required from reference monitor policy adapters.
  """
  @callback permission(
    subject :: term,
    object :: term,
    access_mode :: atom,
    access_param :: term
  ) :: MapSet.t()
  @callback filter(
    subject :: term,
    object :: term,
    access_mode :: atom,
    access_param :: term,
    deny_or_allow :: :deny | :allow
  ) :: boolean
  @callback audit(
    subject :: term,
    object :: term,
    access_mode :: atom,
    access_param :: term,
    deny_or_allow :: :deny | :allow
  ) :: :ok

  defmacro __using__(_opts) do
    quote do
      @behaviour Refmon.Adapter
      require Logger

      def permission(subject, object, access_mode, access_param), do: :allow
      def filter(subject, object, access_mode, access_param, deny_or_allow), do: false

      def audit(subject, object, access_mode, access_param, deny_or_allow) do
        message = "#{deny_or_allow} #{access_mode}(#{access_param}): subject=#{subject}, object=#{object}"
        Logger.info(message, audit_log: true)
      end

      defoverridable Refmon.Adapter
    end
  end
end
