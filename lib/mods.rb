# frozen_string_literal: true

# Load all of the modules that are in the app included what's installed
def allmods(force = false)
  if $allmods && force == false
    $allmods
  else
    modtypes = ['core|!tog/modules/core/', 'extensions|!tog/modules/extensions/', 'custom|!tog/modules/custom/', 'installed|!tog/' + $settings_path, 'beta|!tog/modules/beta/']
    debug(5, 'Building $allmods')
    allmods = {}

    modtypes.each do |modtype|
      modcode = modtype.split('|').first
      moddir = modtype.split('|').last
      allmods[modcode] = []
      if modcode == 'installed'
        module_files = Dir.glob(togpath(moddir) + '*.rb')
        module_files.each do |mod|
          modname = File.basename(mod, '.rb')
          allmods[modcode] << modname
        end
      else
        module_files = Dir.glob(togpath(moddir) + '*-actions.rb')
        module_files.each do |mod|
          modname = File.basename(mod, '.rb').split('-').first
          allmods[modcode] << modname
        end
      end
    end
    allmods['notinstalled'] = allmods['core'] + allmods['extensions'] + allmods['custom'] - allmods['installed']
    allmods['notinstalledplus'] = allmods['core'] + allmods['extensions'] + allmods['custom'] + allmods['beta'] - allmods['installed']

    $allmods = allmods
    debug(5, allmods)
    allmods
  end
end

def check_gem_installed(gem, extrainfo = nil)
  unless $checked_gems&.include?(gem)
    if Gem::Specification.find_all_by_name(gem).count > 0
      $checked_gems = $checked_gems.to_s + gem + '|'
      true
    else
      gem_alert(gem, extrainfo)
    end
  end
end

def is_installed(mod)
  if File.exist?(pathify($settings_path, mod))
    true
  else
    false
  end
end

def installmod(mod)
  destination = pathify($settings_path, mod)
  debug(5, 'Installing to.. ')
  debug(5, destination)
  if allmods['notinstalledplus'].include?(mod) ||
     debug(5, 'Installing: + mod')
    modtype = allmods.find { |_key, values| values.include?(mod) }.first
    source = pathify(dirslash('modules/' + modtype), mod, '-default-settings')
    if File.exist?(source)
      if File.exist?(destination)
        togprint('h2', "Wait.. that's already installed")
      else
        togprint('h2', 'Installing Extension :: ' + mod)

        FileUtils.cp(source, destination)
        load_mod mod
        help_head mod
        command = mod + '_help'
        eval(command)
        exit
      end
    else
      togprint('h2', 'The settings file is missing for that module.')
    end
  else
    togprint('h2', "Can't seem to find that module!")
  end
end

def uninstallmod(mod)
  settings = pathify($settings_path, mod)
  if File.exist?(settings)
    togprint('h2', 'Removing Extension :: ' + mod)
    FileUtils.mv(settings, '/tmp')
    allmods force = true
  else
    togprint('h2', "Can't uninstall a module that's not installed")
  end
end

def install_if_missing(mods)
  mods.each do |mod|
    installmod mod if is_installed(mod) == false
  end
end

def load_mod_dependencies
  load_mod_settings
  # Now load all mod libs
  load_mods 'core', '-lib'
  load_mods 'extensions', '-lib'
  load_mods 'custom', '-lib'
  load_mods 'beta', '-lib'
end

def load_mod_actions
  load_mods 'core', '-actions'
  load_mods 'extensions', '-actions'
  load_mods 'custom', '-actions'
  load_mods 'beta', '-actions'
end

def load_mod_settings
  settings = Dir.glob(togpath('!tog/' + $settings_path) + '*.rb')
  settings.each do |setting|
    load setting
  end
end

def load_mod(mod)
  modtype = allmods.find { |_key, values| values.include?(mod) }.first
  load(pathify($settings_path, mod))
  load(pathify('modules/' + modtype + '/', mod, '-lib'))
  load(pathify('modules/' + modtype + '/', mod, '-actions'))
end

def load_mods(modtype, postfix)
  mods = allmods[modtype] & allmods['installed']
  mods.each do |mod|
    load(pathify('modules/' + modtype + '/', mod, postfix))
  end

  # Just a little something so that I can keep all the settings files as the defaults but override just for me
  # Life a bit easier that way.
  if File.exist?(togpath('!tog/' + $settings_path + 'overrides.rb'))
    load(togpath('!tog/' + $settings_path + 'overrides.rb'))
  end
end
