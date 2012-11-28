describe :validate do
  it "validates the keys in a hash" do
    lambda {
      validate({"a"=>nil, "b"=>nil}, "a", "b")
    }.should_not raise_error

    lambda {
      validate({"a"=>nil, "b"=>nil}, "c")
    }.should raise_error
  end
end
