defimpl Jason.Encoder, for: [MapSet, Range, Stream] do
  def encode(struct, opts) do
    Jason.Encode.list(Enum.to_list(struct), opts)
  end
end

defimpl Jason.Encoder, for: Tuple do
  def encode(struct, opts) do
    struct
    |> Tuple.to_list()
    |> Jason.Encode.list(opts)
  end
end
