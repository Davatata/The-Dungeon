class Weapon
  attr_accessor :name,:durability,:base_damage,:increased_damage
  def initialize(n,d,b)
    @name = n
    @durability = d
    @base_damage = b
    @increased_damage = get_increased_damage()
  end

  def get_increased_damage()
    multiplier = 0.0
    x = rand(0..99)
    if x > 94
      multiplier = (rand(1.7..2.0)*100).round / 100.0
    elsif x > 64
      multiplier = (rand(1.3..1.5)*100).round / 100.0
    elsif x > 34
      multiplier = (rand(1.1..1.3)*100).round / 100.0
    else
      multiplier = 1.0
    end
    multiplier
  end

  def fortify(n)
    @base_damage += n
  end

  def repair(n)
    @durability += n
  end

  def do_damage()
    @durability -= reduce_durability()
    @durability = 0 if @durability <= 0
    crit = rand(0..99)
    if crit > 96
      crit = 2
    else
      crit = 1
    end
    @base_damage * @increased_damage * crit
  end

  def reduce_durability()
    x = rand(0..99)
    if x > 89
      reduction = 2
    elsif x > 49
      reduction = 1
    else
      reduction = 0
    end
    reduction
  end
end
