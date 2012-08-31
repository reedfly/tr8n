#!/usr/bin/env ruby

# https://developers.google.com/closure/compiler/
# http://developer.yahoo.com/yui/compressor
require 'rubygems'
require 'pp'
require 'yaml'
require 'fssm'

pp "Started monitoring ./src folder. To stop use Ctrl+C."

FSSM.monitor('./src/', '**/*') do
  update do |base, relative|
    pp "#{relative} file changed"
    compile
  end

  delete do |base, relative|
    pp "#{relative} deleted"
    compile
  end

  create do |base, relative|
    pp "#{relative} created"
    compile
  end

  def config
    @config ||= YAML.load_file("config.yml")
  end

  def compile
    comments_regexp = /\/\*(!)*[^*]*\*+(?:[^*\/][^*]*\*+)*\//

    output_path = "../../public/tr8n/javascripts"
  
    File.open("#{output_path}/tr8n.js", 'w') do |file| 
      config['all'].split(" ").each do |fl|
        pp "Processing #{fl}..."
        content = File.read(fl)
        content = content.gsub(comments_regexp, '')        
        file.write(content)
      end
    end

    command = "java -jar compressors/google/compiler.jar --js #{config['all']} --js_output_file #{output_path}/tr8n-compiled.js; echo 'Done'"
    pp command
    Kernel.spawn(command)
  end

end

