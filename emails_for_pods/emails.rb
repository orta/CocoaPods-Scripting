require 'cocoapods-core'
require 'cocoapods'
require 'set'

class Array
  def listify
    length < 2 ? first.to_s : "#{self[0..-2] * ', '} and #{last}"
  end
end

module Pod
  class Specification
    def or_contributors_to_spec
      return self.authors if self.authors.is_a? String
      return self.authors.listify if self.authors.is_a? Array
      return self.authors.values.listify if self.authors.is_a? Hash
    end
  end
end

$current_dir = File.dirname(File.expand_path(__FILE__)) 
$active_folder = $current_dir + "/../Specs/Specs"

@emails = SortedSet.new

# Get the licenses + use count and order by popularity

def get_pod_emails_in_argv pod_path
  
  begin 
    spec = Pod::Specification.from_file pod_path
    if ARGV.include? spec.name
      @emails << spec.or_contributors_to_spec
    end
  rescue Exception => e
    p e
  end
end


def print_emails
  for key in @emails
    if key.include? "@"
      puts key
    end
  end
end

@method = :get_pod_emails_in_argv
@done = :print_emails

Dir.foreach $active_folder do |pod|
  
  next if pod[0] == '.'
  next unless File.directory? "#{$active_folder}/#{pod}/"
  
  Dir.foreach $active_folder + "/#{pod}" do |version|
    next if version[0] == '.'
    next unless File.directory? "#{$active_folder}/#{pod}/#{version}/"
    
    self.send @method, "#{$active_folder}/#{pod}/#{version}/#{pod}.podspec.json"
  end
end

self.send @done
