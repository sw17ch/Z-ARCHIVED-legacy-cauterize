describe String do
  describe :snake do
    it "converts a string to snake case" do
      "HelloWorld".snake.should == "Hello_World"
    end
  end

  describe :up_snake do
    it "converts a string to upper case snake case" do
      "HelloWorld".up_snake.should == "HELLO_WORLD"
    end
  end

  describe :down_snake do
    it "converts a string to lower case snake case" do
      "HelloWorld".down_snake.should == "hello_world"
    end
  end
end
