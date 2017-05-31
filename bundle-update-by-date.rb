require 'rubygems'
require 'gems'

target_date = Time.parse(ARGV[0])

gem_names = []
File.open('./Gemfile') do |file|
  file.each_line do |line|
    gem = line.match(/gem \'([\w|-]*)\'/)
    gem_names << gem[1] if gem
  end
end

gem_names.each do |gem_name|
  versions = Gems.versions(gem_name)
  versions.map! do |v|
    number = v['number']
    built_at = Time.parse(v['built_at']).getlocal
    if target_date > built_at && !number.include?('rc') && !number.include?('beta') && !number.include?('pre')
      [number, built_at]
    end
  end.compact!
  
  latest = versions.first
  latest_version = latest[0]
  # puts latest.unshift("- #{gem_name}").join(', ')
  
  response = `gem list ^#{gem_name}$`
  response_line = response.match(/#{gem_name} \((\d.+)\)/)
  local_version = response_line[1] if response_line
  
  if !response_line || local_version < latest_version
    puts "bundle update #{gem_name} -v #{latest_version}"
  end
end
