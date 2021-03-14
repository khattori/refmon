defmodule Refmon.Extras.TestKernel do
  use Refmon

  def access() do
    validate("obj", :use)
    validate!("obj", :use)
    validate("subj", "obj", :read)
    validate!("subj", "obj", :write)
    :ok
  end
end
