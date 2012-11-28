def validate(hash, *keys)
  h_keys = hash.keys
  unless keys == keys & h_keys
    raise "Missing keys: #{(keys - h_keys).join(", ")}."
  end
end
