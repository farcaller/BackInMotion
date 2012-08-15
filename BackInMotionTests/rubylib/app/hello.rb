class Hello
  attr_reader :string

  def initialize(string)
    @string = string
  end
  
  def description
    "<Hello #{@string}>"
  end
end
