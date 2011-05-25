require 'yaml'
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
conversion_array = YAML.load("./zh-CN.yml")
scan_dirs.each do |dir|
  Dir.entries("./app/#{dir}").each do |file| 
    if file!=".." && file!="."
      File.open("./app/#{dir}/#{file}") do |f| 
        filestr = f.readlines.to_s if File.stat("./app/#{dir}/#{file}").file?
        File.open("./app/#{dir}/#{file}.bak", "w") do |f2|
          f2.puts filestr
        end 
        conversion_array.each do |key, value|
          filestr = filestr.gsub(/#{value}/,"<%=t(:#{key})%>")
        end
        #chinese_words << filestr.scan(/[\u4e00-\u9fff]+/) if filestr
      end
      File.open("./app/#{dir}/#{file}", "w") do |f|
        f.puts filestr
      end
    end
  end
end