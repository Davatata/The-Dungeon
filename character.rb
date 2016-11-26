class Character
  attr_accessor :name,:health,:weapon,:inventory,:max_health,:been_seen
  def initialize(n,h,w)
    @name = n
    @health = h
    @inventory = []
    @max_health = h
    @been_seen = false
    @weapon = w
  end

  def print_info()
    if @weapon == nil
      "#{@name[0..7]}\t#{@health.round(2)}\tBare Hands"
    else
      "#{@name[0..7]}\t#{@health.round(2)}\t#{@weapon.name}\t#{@weapon.durability}\t#{@weapon.base_damage}\t#{@weapon.increased_damage}"
    end
  end

  def fortify_health(n)
    @max_health += n
  end

end
