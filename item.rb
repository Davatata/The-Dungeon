class Item
  attr_accessor :name,:value
  def initialize(n,v)
    @name = n
    @value = v.to_f
  end
end
