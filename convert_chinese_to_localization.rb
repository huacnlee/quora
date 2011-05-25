require 'yaml'
require 'fileutils'
chinese_words = []
scan_dirs = [
  "views/answers",
  "views/asks",
  "views/comments",
  "views/cpanel",
  "views/devise",
  "views/errors",
  "views/home",
  "views/layouts",
  "views/logs",
  "views/registrations",
  "views/shared",
  "views/topics",
  "views/user_mailer",
  "views/users"
]
conversion_hash = YAML.load_file("./zh-CN.yml")
scan_dirs.each do |dir|
  Dir.entries("./app/#{dir}").each do |file| 
    if file.match(/\.bak\.erb$/)
      FileUtils.cp("./app/#{dir}/#{file}", "./app/#{dir}/#{file.gsub(/^1_/,'').gsub(/\.bak\.erb/,'')}")
      File.delete("./app/#{dir}/#{file}")
    else
      if file!=".." && file!="."
        if File.stat("./app/#{dir}/#{file}").file?
          FileUtils.cp("./app/#{dir}/#{file}", "./app/#{dir}/1_#{file}.bak.erb")
          File.open("./app/#{dir}/#{file}") do |f| 
            @filestr = f.readlines.join("")
            chinese_words = @filestr.scan(/[\u4e00-\u9fff]+/)
            chinese_words.each do |value|
              key = conversion_hash.key(value)
              if key
                
                @filestr = @filestr.gsub(/placeholder="([^"]*)#{value}([^"]*)"/,"placeholder=\"\\1<%=t(:#{key})%>\\2\"")
                @filestr = @filestr.gsub(/"([^"<>]*)#{value}([^<>"]*)"/,"\"\\1\#{t(:#{key})}\\2\"")
                @filestr = @filestr.gsub(/'#{value}'/,"\"\#{t(:#{key})}\"")
                @filestr = @filestr.gsub(/#{value}/,"<%=t(:#{key})%>")
              else
                puts "could not find key for #{value}"
              end
            end
            #chinese_words << filestr.scan(/[\u4e00-\u9fff]+/) if filestr
          end
          File.open("./app/#{dir}/#{file}", "w") do |f|
            f.puts @filestr
          end
        end
      end
    end
  end
end