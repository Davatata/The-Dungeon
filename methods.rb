require_relative 'rooms.rb'

def make_weapon(str)
  arr = str.split(",")
  return nil if arr.size != 3
  Weapon.new(arr[0], arr[1].to_f * 1.5, arr[2].to_f)
end

def make_item(str)
  arr = str.split(",")
  return nil if arr.size != 2
  Item.new(arr[0], arr[1].to_f)
end

def make_enemy()
  chance = rand(0..999)
  current_enemy = []
  weapon = nil
  if chance == 999
    $myth_exists = true
    current_enemy = $legendary_enemies.sample.split(",")
    weapon = make_weapon($legendary_weapons.sample)
  elsif chance > 499
    current_enemy = $strong_enemies.sample.split(",")
    weapon = make_weapon($strong_weapons.sample)
  else
    current_enemy = $weak_enemies.sample.split(",")
    weapon = make_weapon($simple_weapons.sample)
  end

  name = current_enemy[0]
  health = current_enemy[1].to_f

  Character.new(name, health, weapon)
end

# welcome the player, get their name, ask them when ready and wish them luck
def display_welcome()
  min = 10
  max = 50
  puts
  puts "Welcome to The Dungeon..."
  while true do
    puts
    puts "What is your name?"
    name = gets.chomp
    if name.match(/[0-9]|\W/)
      puts "Enter letters only."
      next
    end
    break
  end
  puts
  puts "How many rooms does the dungeon have?"
  puts "The villager said it was between #{min} and #{max}..."
  while true do
    input = gets.chomp.to_i
    if input.between?(min,max)
      $number_of_rooms = input
      break
    else
      puts "The villager said it was between #{min} and #{max}..."
    end
  end
  puts "You are now entering the dungeon, good luck #{name}...\n"
  name
end

def get_weapon()
  r = rand(0..99)
  weapon = nil
  if r > 79
    put_weap = rand(0..999)
    if put_weap == 999 || $myth_exists
      $myth_exists = false
      weapon = make_weapon($legendary_weapons.sample)
    elsif put_weap > 689
      weapon = make_weapon($strong_weapons.sample)
    else
      weapon = make_weapon($simple_weapons.sample)
    end
  end
  weapon
end

def get_item()
  r = rand(0..99)
  item = nil
  if r > 89
    item = make_item($items.sample)
  end
  item
end

def create_grid(n)
  Array.new((n*2)-1) { Array.new((n*2)-1, 0) }
end

def clear_zeros_columns()
  while true do
    arr = []
    room_exists = false
    $rooms_array.each {|r| arr.push(r.first)}
    if arr.all? {|i| i == 0}
      $rooms_array.each {|r| r.shift}
    else
      break
    end
  end

  while true do
    arr = []
    room_exists = false
    $rooms_array.each {|r| arr.push(r.last)}
    if arr.all? {|i| i == 0}
      $rooms_array.each {|r| r.pop}
    else
      break
    end
  end

end

def get_random_direction(x,y)
  available = []
  available.push([x-1,y]) if $rooms_array[x-1][y] == 0
  available.push([x+1,y]) if $rooms_array[x+1][y] == 0
  available.push([x,y-1]) if $rooms_array[x][y-1] == 0
  available.push([x,y+1]) if $rooms_array[x][y+1] == 0
  # print available
  # puts "is available "
  if !available.empty?
    direction = available.sample
  else
    nil
  end
end

def print_current_array(arr)

  puts "There are #{$number_of_enemies} enemies left"
  puts
  arr.each do |row|
    print "\t"
    row.each do |item|
      if item == 0
        print 0.to_s + " "
      elsif item == $current_room
        print "x "
      elsif item.class == Character and item.been_seen
        print "e"
      else
        print ". "
      end
    end
    puts
  end
end

def get_doors(room)
  arr = []
  arr.push("w") if room.rooms[:up] != nil
  arr.push("s") if room.rooms[:down] != nil
  arr.push("a") if room.rooms[:left] != nil
  arr.push("d") if room.rooms[:right] != nil
  arr
end

def get_inventory(room_or_player)
  room_or_player.inventory
end

def get_non_weapon(player)
  arr = []
  player.inventory.each do |i|
      if i.class == Item
        arr.push(i)
        puts "testing"
        puts i.name
      end
  end
  arr
end

def display_room_contents(room)
  puts "\e[H\e[2J"
  print_current_array($rooms_array)
  puts
  puts "There is an enemy: " + get_stats(room.enemy) + "\n" if !room.enemy.nil?
  if !room.inventory.empty?
    room_inv = get_inventory(room)
    puts "Room has: "
    room_inv.each {|i| puts "-- " + i.name + " "}
  end
  puts "Room is empty." if room.enemy.nil? and room.inventory.empty?
  puts
  # puts "Doors: " + get_doors(room).join(" ")
  puts
end

def get_stats(character)
  character.print_info()
end

def call_help(room,player)
  arr = []
  arr.push("-- (v) Inventory")
  if room.enemy.nil?
    arr.push("-- (#{get_doors(room).join(",")}) Move")
  else
    arr.push("-- (f) Fight")
    arr.push("-- (#{$came_from}) Move")
  end
  if !room.inventory.empty?
    arr.push("-- (c) Grab")
    inv = get_inventory(room).map{|e| e.name}
    inv.each_with_index do |v,i|
      arr.push("\t#{i} -> #{v}")
    end
  end
  if !$current_player.inventory.empty?
    arr.push("-- (x) Drop")
    arr.push("-- (q) Use") if has_Item?($current_player.inventory)
    arr.push("-- (e) Equip") if has_Weapon?($current_player.inventory)
  end


  puts "Options: " if !arr.empty?
  arr.each do |a|
    puts a
  end
  puts
end

def has_Item?(arr)
  arr.any? { |e| e.class == Item  }
end

def has_Weapon?(arr)
  arr.any? { |e| e.class == Weapon }
end

def print_adjacent_rooms(room)
  return nil if room == nil
  top =   room.rooms[:up] != nil ? " x " : "   "
  down =  room.rooms[:down] != nil ? " x " : "   "
  left =  room.rooms[:left] != nil ? "x" : " "
  right = room.rooms[:right] != nil ? "x" : " "

  puts top
  puts left + "R" + right
  puts down
end

def assign_neighbors(x,y)
  if $rooms_array[x-1][y] != 0
    $rooms_array[x-1][y].rooms[:down] = $rooms_array[x][y]
    $rooms_array[x][y].rooms[:up] = $rooms_array[x-1][y]
  end
  if $rooms_array[x+1][y] != 0
    $rooms_array[x+1][y].rooms[:up] = $rooms_array[x][y]
    $rooms_array[x][y].rooms[:down] = $rooms_array[x+1][y]
  end
  if $rooms_array[x][y-1] != 0
    $rooms_array[x][y-1].rooms[:right] = $rooms_array[x][y]
    $rooms_array[x][y].rooms[:left] = $rooms_array[x][y-1]
  end
  if $rooms_array[x][y+1] != 0
    $rooms_array[x][y+1].rooms[:left] = $rooms_array[x][y]
    $rooms_array[x][y].rooms[:right] = $rooms_array[x][y+1]
  end
end

def used_three_doors(room)
  count = 0
  count += 1 if room.rooms[:up] != nil
  count += 1 if room.rooms[:down] != nil
  count += 1 if room.rooms[:left] != nil
  count += 1 if room.rooms[:right] != nil
  count >= 3
end

def delete_item_and_clear(pos)
  $current_player.inventory.delete_at(pos)
  display_room_contents($current_room)
end

def use_item(item,pos)

  arr = item.split("(")    # => ["Health Potion", "+50)"]
  item_name = arr[0]       # => "Health Potion"
  item_val = arr[1].chop   # => "+50"
  item_op = item_val[0]    # => "+"
  item_val[0] = ''         # => "50"
  item_val = item_val.to_f # => 50

  case item_name
  when "Health Potion"
    if $current_player.health + item_val > $current_player.max_health
      $current_player.health = $current_player.max_health
    else
      $current_player.health += item_val
    end
    delete_item_and_clear(pos)

    puts "-- You gained +#{item_val} health"
    puts $current_player.print_info
  when "Fortify Weapon"
    if $current_player.weapon.nil?
      puts "-- Must fortify a weapon"
    else
      $current_player.weapon.fortify(item_val)
      delete_item_and_clear(pos)

      puts "-- Your weapon gained +#{item_val} damage"
      puts $current_player.print_info
    end
  when "Fortify Health"
      $current_player.fortify_health(item_val)
      delete_item_and_clear(pos)

      puts "-- Your max health increased by +#{item_val}"
    when "Repair Kit"
      if $current_player.weapon.nil?
        puts "-- Must repair a weapon"
      else
        $current_player.weapon.repair(item_val)
        delete_item_and_clear(pos)

        puts "-- Your weapon gained +#{item_val} durability"
        puts $current_player.print_info
      end
  else
    puts "Unknown item"
  end
end

def equip_item()
  if $current_player.inventory.any? { |e| e.class == Weapon  }
    arr = []
    inv = get_inventory($current_player).map{|e| e.name}
    arr.push("-- Enter # to be equipped")
    inv.each_with_index do |v,i|
      arr.push("\t#{i} -> #{v}") if $current_player.inventory[i].class == Weapon
    end
    arr.each do |a|
      puts a
    end
    puts
    equip_pos = STDIN.getch.to_i
    if !(0..9).to_a.include?(equip_pos)
      puts "-- Can't enter letter for position"
    else
      if $current_player.inventory[equip_pos] != nil
        if $current_player.inventory[equip_pos].class == Weapon
          weap = $current_player.weapon
          $current_player.weapon = $current_player.inventory[equip_pos]
          $current_player.inventory[equip_pos] = weap
          puts "-- Equipped #{$current_player.weapon.name}"
        else
          puts "-- Must equip a weapon"
        end
      else
        puts "-- Nothing at that position to equip"
      end
    end
  else
    puts "-- Nothing to equip"
    puts
  end
end

def inventory_has_weapon?(inventory,weapon_name)
  inventory.each do |i|
    if i.name == weapon_name
      return true
    end
  end
  false
end

def grab_weapon(weapon_name)
  weap = nil
  $current_room.inventory.each do |i|
    if i.name == weapon_name
      weap = i
    end
  end
  if !weap.nil?
    $current_room.inventory.delete(weap)
  else
    nil
  end
  display_inventory()
end

def get_direction(direction)
  if direction == "w"
    $came_from = "s"
    $current_room.up
  elsif direction == "s"
    $came_from = "w"
    $current_room.down
  elsif direction == "a"
    $came_from = "d"
    $current_room.left
  else
    $came_from = "a"
    $current_room.right
  end
end

def call_move(room,input)
  if !$current_room.enemy.nil? and input != $came_from
    puts "There's an enemy! Can only press #{$came_from}"
    $current_room.enemy.been_seen = true
  elsif input == "w" and !room.rooms[:up].nil?
    $current_room = room.rooms[:up]
    $came_from = "s"
    display_room_contents($current_room)
  elsif input == "s" and !room.rooms[:down].nil?
    $current_room = room.rooms[:down]
    $came_from = "w"
    display_room_contents($current_room)
  elsif  input == "a" and !room.rooms[:left].nil?
    $current_room = room.rooms[:left]
    $came_from = "d"
    display_room_contents($current_room)
  elsif input == "d" and !room.rooms[:right].nil?
    $current_room = room.rooms[:right]
    $came_from = "a"
    display_room_contents($current_room)
  else
    puts "Can't move in that direction."
  end
end

def get_command(room,player)
  # possible_commands = %w(help move grab drop equip inventory use map fight)
  possible_commands = %w(w a s d e x q v m f h r c /)
  # input = gets.chomp
  input = STDIN.getch.downcase
  # arr = input.split(/\s+/)
  # arr.map! {|i| i.downcase }
  if !possible_commands.include?(input)
    puts "-- Bad input. Try again."
  else
    display_room_contents($current_room)
    if input == "h"
      call_help($current_room,$current_player)
    elsif input == "w"
      call_move(room,input)
    elsif input == "a"
      call_move(room,input)
    elsif input == "s"
      call_move(room,input)
    elsif input == "d"
      call_move(room,input)
    elsif input == "c"
      if $current_room.inventory.empty?
        puts "Nothing to grab."
      else
        $current_player.inventory.push($current_room.inventory.shift)
        display_room_contents($current_room)
        puts "-- #{$current_player.inventory.last.name} was added to inventory"
        puts
      end
    elsif input == "x"
      if !$current_player.inventory.empty?
        arr = []
        inv = get_inventory($current_player).map{|e| e.name}
        arr.push("-- Enter # to be dropped")
        inv.each_with_index do |v,i|
          arr.push("\t#{i} -> #{v}")
        end
        arr.each do |a|
          puts a
        end
        puts
        drop_pos = STDIN.getch.to_i
        if $current_player.inventory[drop_pos] != nil
          $current_room.inventory.push($current_player.inventory.delete_at(drop_pos))
          puts "-- Dropped #{$current_room.inventory.last.name}"
        else
          puts "-- Couldn't drop that"
        end
      end
    elsif input == "e"
      equip_item()
    elsif input == "v"
      display_inventory()
    elsif input == "/"
      you_lose()
    elsif input == "q"
      use_from_inventory()
    elsif input == "f"
      if $current_room.enemy.nil?
        puts "There's no enemy to fight."
      else
        finished = false
        while !finished do
          puts "\t\tName\tHealth\tWeapon\t\tDurab\tBaseDmg\t+Dmg"
          puts "\tEnemy: " + get_stats($current_room.enemy)
          puts "\tYou:   " + get_stats($current_player)
          puts "\nYour options: \n-- (f) attack\n-- (v) inventory\n-- (q) use\n-- (e) equip\n-- (r) run away"
          possible_actions = %w(f v q e r)
          fight_input = STDIN.getch.downcase
          # farr = fight_input.split(/s+/).map!{|e| e.downcase}
          if fight_input == "r"
            if $came_from == "w"
              $current_room = $current_room.rooms[:up]
              display_room_contents($current_room)
              finished = true
            elsif $came_from == "s"
              $current_room = $current_room.rooms[:down]
              display_room_contents($current_room)
              finished = true
            elsif $came_from == "a"
              $current_room = $current_room.rooms[:left]
              display_room_contents($current_room)
              finished = true
            elsif $came_from == "d"
              $current_room = $current_room.rooms[:right]
              display_room_contents($current_room)
              finished = true
            end
          elsif fight_input == "v"
            display_room_contents($current_room)
            display_inventory()
          elsif fight_input == "q"
            display_room_contents($current_room)
            use_from_inventory()
          elsif fight_input == "e"
            display_room_contents($current_room)
            equip_item()
          elsif fight_input == "f"
            display_room_contents($current_room)
            exchange_blows()
            if $current_room.enemy.health <= 0.0
              $current_room.enemy = nil
              puts "-- Enemy defeated!"
              if roll_percent?(20)
                $current_room.inventory.push(make_item($items.sample))
                puts "-- " + $current_room.inventory.last.name + " was dropped!"
              end
              if roll_percent?(5)
                $current_room.inventory.push(make_item($repairs.sample))
                puts "-- " + $current_room.inventory.last.name + " was dropped!"
              end
              
              $current_room.inventory.push(make_item($potions.sample))
              display_room_contents($current_room)

              puts "-- " + $current_room.inventory.last.name + " was dropped!"
              puts
              $number_of_enemies -= 1
              if $number_of_enemies == 0
                you_win()
              else
                puts $number_of_enemies
              end
              break
            elsif $current_player.health <= 0.0
              you_lose()
            else
              display_room_contents($current_room)
            end
          elsif fight_input == "/"
            you_lose()
          else
            display_room_contents($current_room)
          end
        end
      end
    elsif input == "m"
      display_room_contents($current_room)
    end
    call_help($current_room,$current_player)
  end
end

def roll_percent?(n)
  rand(0..99) < n ? true : false
end

def use_from_inventory()
  if !$current_player.inventory.empty?
    if  $current_player.inventory.any?{|e| e.class == Item}
      arr = []
      inv = get_inventory($current_player).map{|e| e.name}
      arr.push("-- Enter # to be used")
      inv.each_with_index do |v,i|
        arr.push("\t#{i} -> #{v}") if $current_player.inventory[i].class == Item
      end
      arr.each do |a|
        puts a
      end
      puts
      use_pos = STDIN.getch.to_i
      item = $current_player.inventory[use_pos]
      if !item.nil?
        if item.class == Item
          use_item(item.name, use_pos)
        end
      else
        puts "-- Don't have that item to use."
      end
    end
  else
    puts "-- Inventory empty"
    puts
  end
end

def display_inventory()
  if $current_player.inventory.empty?
    puts "Inventory is empty."
  else
    print "Inventory: "
    puts "\tItem\t\tAmount"
    $current_player.inventory.each do |w|
      puts "\t\t#{w.name}\t#{w.value}" if w.class == Item
    end
    puts
    puts "\t\tWeapon\t\tDurab\tBaseDmg\t+Dmg"

    $current_player.inventory.each do |w|
      puts "\t\t#{w.name}\t#{w.durability}\t#{w.base_damage}\t#{w.increased_damage}" if w.class == Weapon
    end
    w = $current_player.weapon
    puts " -- (equipped)  #{w.name}\t#{w.durability}\t#{w.base_damage}\t#{w.increased_damage}"
    puts
  end
end

def exchange_blows()

  if $current_player.weapon.nil? or $current_player.weapon.durability <= 0.0
    $current_room.enemy.health -= 1
  else
    $current_room.enemy.health -= $current_player.weapon.do_damage
  end

  if $current_room.enemy.health > 0.0
    if $current_room.enemy.weapon.nil? or $current_room.enemy.weapon.durability <= 0.0
      $current_player.health -= 1
    else
      $current_player.health -= $current_room.enemy.weapon.do_damage
    end
  end
end

def you_lose()
  puts "\e[H\e[2J"
  puts "You have died..."
  STDIN.getch.downcase
  exit
end

def you_win()
  puts "\e[H\e[2J"
  puts "Congrats #{$current_player.name}!"
  puts
  puts "Last enemy killed! You win!"
  STDIN.getch.downcase
  exit
end

def fill_rooms_array(n)
  enemies_left = $number_of_enemies
  current_room = Room.new()
  rooms_made = 1
  room_positions = []
  room_positions.push([n-1,n-1])
  $rooms_array[n-1][n-1] = current_room

  (n-1).times do |i|
    room = Room.new()
    item = get_item()
    weap = get_weapon()
    room.inventory.push(weap) if weap != nil
    room.inventory.push(item) if item != nil

    if enemies_left + i > (n-2)
      room.enemy = make_enemy()
      enemies_left -= 1
    else
      chance = rand(0..99)
      if chance > 74
        room.enemy = make_enemy()
        enemies_left -= 1
      end
    end

    # get a random room that doesnt have 4 adjacent rooms
    random_coord = room_positions.sample
    x = random_coord[0]
    y = random_coord[1]
    while used_three_doors($rooms_array[x][y])  do
      random_coord = room_positions.sample
      x = random_coord[0]
      y = random_coord[1]
    end

    new_coord = get_random_direction(x,y)
    new_x = new_coord[0]
    new_y = new_coord[1]

    $rooms_array[new_x][new_y] = room
    assign_neighbors(new_x,new_y)

    room_positions.push([new_x,new_y])
    rooms_made += 1
  end
end
