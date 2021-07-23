defmodule Refmon.PermissionDenied do
  defexception subject: nil, object: nil, access: nil, param: nil

  def message(me) do
    "permission denied: #{me.subject} have no #{me.access}(#{me.param}) permissions to #{me.object}"
  end
end
