defmodule Refmon.PermissionDenied do
  defexception subject: nil, object: nil, access: nil

  def message(me),
    do: "permission denied: #{me.subject} have no #{me.access} permissions to #{me.object}"
end
