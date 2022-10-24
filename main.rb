# frozen_string_literal: true

require 'English'
require 'json'

def get_env_variable(key)
  ENV[key].nil? || ENV[key] == '' ? nil : ENV[key]
end

def run_command(command)
  puts "@@[command] #{command}"
  exit $CHILD_STATUS.exitstatus unless system(command)
end
env_var_path = get_env_variable('AC_ENV_FILE_PATH') || abort('Missing environment variable path.')
version = get_env_variable('AC_SELECTED_FLUTTER_VERSION') || 'stable'

if `which fvm`.empty?
  run_command('brew tap leoafarias/fvm')
  run_command('brew install fvm')
end

fvm_config = File.join(ENV['AC_REPOSITORY_DIR'], './.fvm/fvm_config.json')
if File.exist?(fvm_config)
  puts 'Found fvm config'
  file = File.read(fvm_config)
  hash = JSON.parse(file)
  version = hash['flutterSdkVersion']
end
puts "Setting version to #{version}"

run_command("fvm global #{version}")
ENV['PATH'] = "#{ENV['PATH']}:#{ENV['HOME']}/fvm/default/bin"
run_command('fvm --version')
File.open(env_var_path, 'a') do |f|
  f.puts "PATH=#{ENV['PATH']}"
end
