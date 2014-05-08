require 'cocoapods-core'
require 'cocoapods'
require 'set'

module Pod
  class Specification
    def or_contributors_to_spec
      return self.authors if self.authors.is_a? String
      return self.authors.listify if self.authors.is_a? Array
      return self.authors.keys.listify if self.authors.is_a? Hash
    end
  end
end

class Array
  def listify
    length < 2 ? first.to_s : "#{self[0..-2] * ', '} and #{last}"
  end
end


# recommend throwing into http://textmechanic.com/Sort-Text-Lines.html 
# then doing natural sort

$current_dir = File.dirname(File.expand_path(__FILE__)) 
$active_folder = $current_dir + "/../specs/"

@users = SortedSet.new
@numbers = {};

# Get the users + use count and order by popularity

def get_all_users pod_path
  
  begin 
    spec = eval( File.open(pod_path).read )

    user = spec.or_contributors_to_spec
    if @users.include? user
      @numbers[user] = @numbers[user] + 1
    else
      @users.add user
      @numbers[user] = 1
    end

  rescue Exception => e
  
  end
end


def get_all_users_done
  @numbers.sort_by {|_key, value| value}

  for key, value in @numbers
   puts value.to_s + " " + key
  end
end

@method = :get_all_users
@done = :get_all_users_done


Dir.foreach $active_folder do |pod|
  
  next if pod[0] == '.'
  next unless File.directory? "#{$active_folder}/#{pod}/"
  
  Dir.foreach $active_folder + "/#{pod}" do |version|
    
    next if version[0] == '.'
    next unless File.directory? "#{$active_folder}/#{pod}/#{version}/"
    
    self.send @method, "#{$active_folder}/#{pod}/#{version}/#{pod}.podspec"
  end
end

self.send @done
