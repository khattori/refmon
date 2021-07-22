defmodule Refmon do
  @moduledoc """
  Documentation for `Refmon`.
  """
  defmacro __using__(_opts) do
    quote do
      require Refmon
      import Refmon, only: :macros

      Module.register_attribute(__MODULE__, :registered_access_modes,
        accumulate: true,
        persist: true
      )
    end
  end

  @refmon_subject_key :refmon_subject_key

  @doc """
  Get version.

  ## Examples

      iex> Refmon.version()
      "0.1.0"

  """
  def version do
    application()
    |> Application.spec(:vsn)
    |> to_string()
  end

  @doc """
  Get OTP application name.

  ## Examples

      iex> Refmon.application()
      :refmon

  """
  def application do
    Application.get_application(__MODULE__)
  end

  @doc """
  Get application environment.
  """
  def get_env(key, default) do
    application()
    |> Application.get_env(key, default)
  end

  @doc """
  Validate that the subject has access rights to the object.

  (The subject is stored in the process context.)

  ## Examples

      iex> validate("my pen", :use)
      :allow
  """
  defmacro validate(obj, acc) when is_atom(acc) do
    Module.put_attribute(__CALLER__.module, :registered_access_modes, acc)

    quote do
      Refmon.subject()
      |> validate(unquote(obj), unquote(acc))
    end
  end

  defmacro validate(_obj, _acc) do
    raise ArgumentError, message: "`acc` parameter should be an atom literal"
  end

  @doc """
  Validate that the subject has access rights to the object.

  ## Examples

      iex> validate("I", "my pen", :use)
      :allow

      iex> validate("he", "my pen", :use)
      :deny
  """
  defmacro validate(subj, obj, acc) when is_atom(acc) do
    Module.put_attribute(__CALLER__.module, :registered_access_modes, acc)

    quote do
      Refmon.Server.validate(unquote(subj), unquote(obj), unquote(acc))
    end
  end

  defmacro validate(_subj, _obj, _acc) do
    raise ArgumentError, message: "`acc` parameter should be an atom literal"
  end

  @doc """
  Version of validate/2 that raises the PermsisionDenied exception.

  ## Examples

      iex> subject("he")
      iex> validate!("his pen", :use)
      :ok

      iex> subject("he")
      iex> validate!("my pen", :use)
      ** (Refmon.PermissionDenied) permission denied: he have no use permissions to my pen
  """
  defmacro validate!(obj, acc) when is_atom(acc) do
    Module.put_attribute(__CALLER__.module, :registered_access_modes, acc)

    quote do
      Refmon.subject()
      |> validate!(unquote(obj), unquote(acc))
    end
  end

  defmacro validate!(_obj, _acc) do
    raise ArgumentError, message: "`acc` parameter should be an atom literal"
  end

  @doc """
  Version of validate/3 that raises the PermsisionDenied exception.

  ## Examples

      iex> validate!("he", "his pen", :use)
      :ok

      iex> validate!("I", "his pen", :use)
      ** (Refmon.PermissionDenied) permission denied: I have no use permissions to his pen
  """
  defmacro validate!(subj, obj, acc) when is_atom(acc) do
    Module.put_attribute(__CALLER__.module, :registered_access_modes, acc)

    quote do
      subj = unquote(subj)
      obj = unquote(obj)

      validate(subj, obj, unquote(acc))
      |> case do
        :allow ->
          :ok

        :deny ->
          raise Refmon.PermissionDenied,
            subject: to_string(subj),
            object: to_string(obj),
            access: unquote(acc)
      end
    end
  end

  defmacro validate!(_subj, _obj, _acc) do
    raise ArgumentError, message: "`acc` parameter should be an atom literal"
  end

  @doc """
  Get the subject stored in the process context.

  ## Examples

      iex> subject()
      nil
  """
  def subject() do
    Process.get(@refmon_subject_key)
  end

  @doc """
  Set the subject into the process context.

  ## Examples

      iex> subject("I")
      nil
  """
  def subject(subj) do
    Process.put(@refmon_subject_key, subj)
  end

  @doc """
  Clear the subject stored in the process context.

  ## Examples

      iex> clear_subject()
      nil
  """
  def clear_subject() do
    Process.delete(@refmon_subject_key)
  end

  @doc """
  Get adapter

  ## Examples

      iex> adapter()
      Refmon.Extras.TestAdapter
  """
  defdelegate adapter(), to: Refmon.Server

  @doc """
  Get access mode list.

  ## Examples

      iex> access_modes()
      #MapSet<[:read, :use, :write]>
  """
  defdelegate access_modes(), to: Refmon.Server
end
