describe Cauterize do
  describe :set_name do
    it "sets the name of the project" do
      set_name("some_name")
      Cauterize.get_name.should == "some_name"
    end
  end

  describe :set_version do
    it "sets a version string" do
      set_version("0.1.2")
      Cauterize.get_version.should == "0.1.2"
    end
  end
end
