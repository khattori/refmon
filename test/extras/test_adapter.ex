defmodule Refmon.Extras.TestAdapter do
  use Refmon.Adapter

  def permissions(subj, obj, perms) do
    case {subj, obj} do
      {"I", "my " <> _} -> perms
      {"he", "his " <> _} -> perms
      {"subj", "obj"} -> perms
      _ -> []
    end
  end
end
