# coding: utf-8

source = File.open("new.txt")
File.open("uni.txt","a") do |f|
  source.each do |line|
    next if line.strip == ""
    line = line.gsub("\n","")
    f.puts "#{line}\t1"
    f.puts "x:1"
  end
end
