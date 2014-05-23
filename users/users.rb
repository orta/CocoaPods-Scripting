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

@users = SortedSet.new
@numbers = {};

# Get the users + use count and order by popularity

def get_all_users(spec)
  user = spec.or_contributors_to_spec
  if @users.include? user
    @numbers[user] = @numbers[user] + 1
  else
    @users.add user
    @numbers[user] = 1
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


config = Pod::Config.new()
source = Pod::Source.new(config.repos_dir + 'master')

source.all_specs.each do |spec|
  self.send @method, spec
end

self.send @done

