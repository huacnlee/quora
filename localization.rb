chinese_words = []
scan_dirs = [
  "controllers",
  "helpers",
  "mailers",
  "models",
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
unless File.exists?("./chinese_words.txt")
  scan_dirs.each do |dir|
    Dir.entries("./app/#{dir}").each do |file| 
      if file!=".." && file!="."
        File.open("./app/#{dir}/#{file}") do |f| 
          filestr = f.readlines.to_s if File.stat("./app/#{dir}/#{file}").file?
          chinese_words << filestr.scan(/[\u4e00-\u9fff]+/).map(&:strip) if filestr
        end
      end
    end
  end
  File.open("./chinese_words.txt", "w+") do |file|
    chinese_words.flatten.uniq.each do |word|
      file.puts word
    end
  end
end

if File.exists?("./english_words.txt")

  chinese_words = File.open("./chinese_words.txt").readlines
  #used google translate to produce the english_words.txt file
  english_words = File.open("./english_words.txt").readlines
  File.open('./zh-CN.yml', 'w') do |f|
    english_words.each_with_index do |e, i|
      f.puts "#{e.downcase.gsub(/[^a-z|1-9| ]|\n/,'').gsub(/ /,"_")}: #{chinese_words[i]}"
    end
  end
  File.open('./en-US.yml', 'w') do |f|
    english_words.each_with_index do |e, i|
      f.puts "#{e.downcase.gsub(/[^a-z|1-9| ]|\n/,'').gsub(/ /,"_")}: \"#{e.gsub(/\n/,'')}\""
    end
  end
else
  puts "Now create your english_words.txt file useing translate.google.com"
  puts "The line numbers must match up."
end