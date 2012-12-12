class String
  def snake
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_")
  end

  def up_snake
    snake.upcase
  end

  def down_snake
    snake.downcase
  end

  def camel
    return self.capitalize if self !~ /_/ && self =~ /[A-z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end
