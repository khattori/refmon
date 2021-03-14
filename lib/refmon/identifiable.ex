defprotocol Refmon.Identifiable do
  @doc """
  Converts `term` to an identifier.
  """
  @spec to_identifier(t) :: String.t() | integer() | atom()
  def to_identifier(term)
end

defimpl Refmon.Identifiable, for: Atom do
  def to_identifier(atom), do: atom
end

defimpl Refmon.Identifiable, for: Integer do
  def to_identifier(int), do: int
end

defimpl Refmon.Identifiable, for: BitString do
  def to_identifier(str) when is_binary(str), do: str

  def to_identifier(term) do
    raise Protocol.UndefinedError,
      protocol: @protocol,
      value: term,
      description: "cannot convert a bitstring to an identifier"
  end
end
