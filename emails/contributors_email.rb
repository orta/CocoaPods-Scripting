# git log --format=email > ../log

require 'set'

emails = SortedSet.new

f = File.open "log"
f.each_line do | l | 
  if l[-2] == '>'
    emails.add l.strip
  end
end

p emails