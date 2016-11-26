class Room
  attr_accessor :inventory, :rooms, :enemy
  def initialize()
    @inventory = []
    @rooms = {:up => nil, :down => nil, :left => nil, :right => nil}
    @enemy = nil
  end
end
