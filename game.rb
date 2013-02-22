require 'colored'
require 'win32console'
require 'io/console'


def create_character() # Creates the character with its details.
puts "Welcome to the game! Please select a name:"
print "> "
name = gets.chomp()
end

def prompt() # The game command prompt
  print "> "
end

def help(command) # Help command, which explains other commands.
info = case command
  when "help" then "Gives a short explanation of the use of every command.\n"
  when "list" then "Lists all available commands. Not every command is available at a certain moment.\n"
  when "shop" then "Opens the shop menu. Only available in certain places.\n"
  when "save" then "Tells the program to save your game.\n"
  when "exit" then "Exits the game.\n"
  when "travel" then "Moves you through the map. Options: North, South, East, West"
  when "look" then "Describes your surroundings."
  else "That is not a command.\n"
end
puts info
end

def travel(direction) # Moves the character to the specified position.
direction = direction.downcase
if $room_data[4].include?(direction) then
  movement = case direction
    when "north" then $room_data[0][0] = $room_data[0][0] - 1
    when "south" then $room_data[0][0] = $room_data[0][0] + 1
    when "east" then $room_data[0][1] = $room_data[0][1] + 1
    when "west" then $room_data[0][1] = $room_data[0][1] - 1
    else puts "That is not a valid direction. Please type North, South, East or West"
  end
  read_room()
else
 puts "Please use one of the available routes."
end

end

def exit() # To exit the game
puts "Do you want to leave the game? yes/no\n"
exiting = gets.chomp()
if exiting == "yes" or exiting == "y"
  Process.exit(0)
elsif exiting == "no" or exiting == "n"
else
  puts "Please answer yes or no.\n"
  exit()
end

end

def list() # To list available commands.
  puts "\n"
  puts "Available commands:\n\n"
  for action in $available_commands.sort()
    puts "#{action}"
  end
end

def look()
puts "#{$room_data[2]}"
end

def examine(item, examine_text)
end


def actions() # Checks which action the character wants to perform and executes the attached script.
prompt()
command = gets.chomp()
if command.include?("help") then
  command = command.sub(/^help /, '')
  command = help(command)
elsif command.include?("travel") then
  command = command.sub(/^travel /, '')
  command = travel(command)
else
  case command
    when "exit" then exit()
    when "list" then list()
	when "look" then look()
	when command.include?("examine") then
	  command = command.sub(/^examine /, '')
	  examine(command)
	when "save" then save_game()
    else 
	puts "Type an available command. Type \"list\" for a list of commands, or \"help command\" for information about a specific one.\n"
    actions()
  end
end

end

def save_game() # Saves the game into a file.
save_files = list_saved_files()

 if save_files.length == 0 then
  puts "There are no saved files. Do you want to create one? yes/no\n"
  savefile_name = gets.chomp()
  if savefile_name == "yes" or savefile_name == "y"
    write_savefile(savefile_name)
  elsif savefile_name != "no" or savefile_name != "n"
    puts "Please answer \"yes\" or \"no\""
  else
    exit()
  end
else
  puts "Please find below the list of saved games."
  puts "Write a number from the list or write a new saved file name.\n"
  save_files = list_saved_files()
  file_counter = display_saved_files(save_files)
  savefile_name = gets.chomp()
  if savefile_name.count("0-9") > 0 and savefile_name.to_i <= file_counter
	savefile_name = savefile_name.to_i - 1
	savefile_name = save_files[savefile_name]
  else
  savefile_name = "save/" + savefile_name + ".sav"
  end
  write_savefile(savefile_name)
end

end

def list_saved_files() # Searchs and stores the list of saved files
require 'find'
Dir.chdir(File.dirname(__FILE__))
save_files = []
Find.find("save") do |path|
  save_files << path if path =~ /.*\.sav$/
end
return save_files
end

def display_saved_files(save_files) # Shows the list of saved files
  file_counter = 0
  
  while file_counter < save_files.length
    save_files[file_counter]= save_files[file_counter].sub(/^save\//, '')
    puts "#{file_counter + 1}.\t#{save_files[file_counter]}".yellow
    file_counter = file_counter + 1
  end
  
return file_counter
end

def write_savefile(filename) # Writes the game information into a saved file.
saved_file = File.open(filename, 'w')
saved_file.write("#{$character_name}\n")

for item in $character_items
  saved_file.write("#{item}, ")
end
saved_file.write("\n")
saved_file.write("#{$room_number}")
saved_file.close()
end

def read_room() # Reads the data from a file and copies the current room information into the global room variable

room_file = IO.readlines("data/rooms.txt")
room_file.each_with_index do |line, index|
  if line.include?("$") and line.chomp() == "$#{$room_data[0][0]},#{$room_data[0][1]}"
      for number in 1..4
	    $room_data[number] = room_file[(index+number)]
		puts $room_data[number]
	  end
	  for number in 6..6+room_file[(index+5)].to_i
	    $room_data[number] = room_file[(index+number)]
	  end
  else
  end
  
end

puts $room_data[1]

end


$character_name = create_character()
$available_commands = ["help", "shop", "travel", "exit", "list", "save"]
$character_items = []
$character_money = 100
$room_data = []
initial_position = [0,0]
$room_data[0] = initial_position
read_room()

puts "\nType a command. Type \"list\" for a list of commands, or \"help command\" for information about a specific one."

while true # Main loop that keep waiting for a command from the player.
  action = actions()
end