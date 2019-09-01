# frozen_string_literal: true

def exittests(message)
  puts '=================================================================================='
  puts 'TESTS FAILED'
  puts '=================================================================================='
  puts message
  exit
end

def test_install_notinstalledmods
  allmods['notinstalled'].each do |mod|
    system('tog install ' + mod)
    exittests('tog install mod failed :: ' + mod) unless is_installed(mod)
  end
end

def test_exists(type, location)
  case type
  when 'file'
    exittests 'MISSING FILE :: ' + location unless File.exist?(location)
  end
end

def test_notexists(type, location)
  case type
  when 'file'
    exittests 'FILE SHOULD NOT BE HERE :: ' + location if File.exist?(location)
  end
end
