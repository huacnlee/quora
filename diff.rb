# coding: utf-8
require "rubygems"
require 'htmldiff'

class Diff
	class << self
		include HTMLDiff
	end
end

t1 = "This is the forst time to useing diff. 魅力的成都\n如果说这里可以活成功."
t2 = "This is my first time to using diff. 美丽的成都\n如果说这里可以或成功。"

f = open("/home/jason/Desktop/a.html","w+")
f.puts Diff.diff(t1,t2)
f.close

