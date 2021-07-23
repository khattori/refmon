defmodule Refmon.Extras.TestAdapter do
  use Refmon.Adapter

  def permission(subj, obj, acc, param) do
    case {subj, obj, acc, param} do
      {_, _, :use, "exclusive"} -> :deny
      {"I", "my " <> _, _, nil} -> :allow
      {"he", "his " <> _, _, nil} -> :allow
      {"subj", "obj", _, nil} -> :allow
      _ -> :deny
    end
  end
end
