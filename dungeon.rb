require_relative 'character'
require_relative 'item'
require_relative 'weapon'
require_relative 'methods'
require 'io/console'
$simple_weapons =  File.open("simple_weapons.txt").to_a.map{|e| e.strip}
$strong_weapons =  File.open("strong_weapons.txt").to_a.map{|e| e.strip}
$legendary_weapons =  File.open("legendary_weapons.txt").to_a.map{|e| e.strip}
$items = File.open("items.txt").to_a.map{|e| e.strip}
$potions = File.open("potions.txt").to_a.map{|e| e.strip}
$repairs = File.open("repairs.txt").to_a.map{|e| e.strip}

$number_of_rooms = 0
$rooms_array = []
$game_over = false
$came_from = nil
$myth_exists = false

# Start of game
$player_name = display_welcome()
$number_of_enemies = $number_of_rooms/2
$weak_enemies = File.open("weak_enemies.txt").to_a.map{|e| e.strip}
$strong_enemies = File.open("strong_enemies.txt").to_a.map{|e| e.strip}
$legendary_enemies = File.open("legendary_enemies.txt").to_a.map{|e| e.strip}
puts

start_weapon = make_weapon($simple_weapons.sample)
$current_player = Character.new($player_name,100,start_weapon)

# need to create array to hold rooms
$rooms_array = create_grid($number_of_rooms)
$rooms_array[$number_of_rooms-1][$number_of_rooms-1] = 'x'

# need to make all the rooms and put in array (give rooms enemies/items)
fill_rooms_array($number_of_rooms)

# assign center of array to current_room and clear array
$current_room = $rooms_array[$number_of_rooms-1][$number_of_rooms-1]

# prints out contents of array for testing
puts
$rooms_array.keep_if { |r| r.any? { |x| x.class == Room }}
# print_current_array($rooms_array)
# puts
clear_zeros_columns()
# tell player where they are and what is in the room
display_room_contents($current_room)

# display "write help on this parchment if you need help"
puts "If you need assistance, type h"
puts
# call_help($current_room,$current_player)

# wait for and accept commands
while !$game_over do
  get_command($current_room,$current_player)
end
