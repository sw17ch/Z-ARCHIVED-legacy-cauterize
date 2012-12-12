describe Cauterize do
  describe :set_name do
    it "sets the name of the project" do
      set_name("some_name")
      Cauterize.get_name.should == "some_name"
    end
  end
end
