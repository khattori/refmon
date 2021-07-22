defmodule Refmon.Extras.TestKernel do
  use Refmon

  def access() do
    Refmon.validate("obj", :use)
    Refmon.validate!("obj", :use)
    Refmon.validate("subj", "obj", :read)
    Refmon.validate!("subj", "obj", :write)
    :ok
  end
end
