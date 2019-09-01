# frozen_string_literal: true

def gem_alert(gem, _text)
  togprint('h1', 'Problem :: Missing Ruby Gem :: ' + gem)
  togprint('p', 'GEMS are libraries of code in the ruby world.  You should be able to install this gem by typing:')
  togprint('p', 'gem install ' + gem)
  exit
end

def qdebug(contents)
  puts '::::' + contents.to_s + ' ::::'
end

def debug(loglevel = 1, contents)
  puts '::::' + contents.to_s + ' ::::' if loglevel <= $debuglevel
end

def togprint(style, contents)
  case style
  when 'h1'
    header = '================================================================================'
    footer = '================================================================================'
    contents = contents.upcase
  when 'h2'
    header = '------------------------------------------------------------'
    footer = '------------------------------------------------------------'
    contents = contents
  when 'error'
    header = nil
    footer = nil
    contents = '', '!-:::::    ' + contents + '    :::::-!', ''

  when 'p'
    header = nil
    footer = nil
    contents = contents, ''
  when 'line'
    contents = contents
  when 'ul'
    footer = '--------------------------------------------------------------------------------'
  end
  puts header unless header.nil?
  puts contents
  puts footer unless footer.nil?
end

def clear_screen
  if $debuglevel > 0
    puts
    puts
    puts
    debug(3, 'CLEARSCREEN')
  else
    system('clear')
  end
end

def menu_from_array(array, prompt = 'Pick One')
  array.each do |element|
    menu_item = (array.index(element) + 1).to_s.rjust(4, ' ') + ') ' + element
    puts menu_item
  end
  puts
  puts prompt
  keyb = $stdin.gets
  choice = keyb.chomp.to_i - 1
  choice
end

def are_you_sure(prompt = 'Are you sure?')
  puts prompt + '  y/N'
  choice = $stdin.gets
  exit unless choice.chomp == 'y'
  system('clear')
end

def get_input(prompt)
  puts prompt
  choice = $stdin.gets
  choice.chomp
end

def yes_no(prompt)
  puts prompt + '  y/n'
  choice = $stdin.gets
  choice.chomp.downcase
end

def help_head(mod, heading = nil)
  blurb = if heading.nil?
            mod.upcase
          else
            heading
          end
  togprint('h2', blurb)
  togprint('line', 'Customize by editing the file: settings/' + mod + '.rb')
  puts
end

def cont(prompt = 'Press ENTER to continue..')
  puts prompt
  choice = $stdin.gets
end

def main_menu(global_menu, set_menu = nil, prompt = 'Pick One')
  menu_actions = {}
  menu_count = 1
  unless set_menu.nil?
    puts 'Current Set Menu'
    set_menu.each do |item|
      puts menu_count.to_s.to_s.rjust(2, ' ') + ') ' + item.split('|').last
      menu_actions[menu_count.to_s] = item.split('|').first
      menu_count += 1
    end
    puts
  end

  puts 'Main Menu'
  global_menu.each do |item|
    puts menu_count.to_s.rjust(2, ' ') + ') ' + item.split('|').last
    menu_actions[menu_count.to_s] = item.split('|').first
    menu_count += 1
  end

  puts
  puts 'Misc'
  puts ' p) Show tog poweruser help'
  menu_actions['p'] = 'power_user_help'
  puts ' h) Show detailed help'
  menu_actions['h'] = 'help'

  if allmods['notinstalled'].count > 0
    puts ' i) Install Modules'
    menu_actions['i'] = 'install'
  end
  puts ' u) Uninstall Modules'
  menu_actions['u'] = 'uninstall'
  puts ' x) Exit'
  menu_actions['x'] = 'exit'

  puts
  puts prompt
  keyb = $stdin.gets
  choice = keyb.chop
  clear_screen
  menu_actions[choice]
end
