defmodule Refmon.Extras.TestKernel do
  use Refmon

  def access() do
    Refmon.validate("obj", :use, nil)
    Refmon.validate!("obj", :use, nil)
    Refmon.validate("subj", "obj", :read, nil)
    Refmon.validate!("subj", "obj", :write, nil)
    :ok
  end
end
