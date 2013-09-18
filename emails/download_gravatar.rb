# "http://gravatar.com/avatar/#{ input }?s=48"

require 'gravatar-ultimate'

f = File.open "emails.txt"
f.each_line do | l | 
    data = Gravatar.new(l.strip).image_data
    p l.strip
    File.open( "images/" + l.strip + ".png", "wb+") do |f|
      f << data
    end
    
end
