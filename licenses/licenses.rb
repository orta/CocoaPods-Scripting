require 'cocoapods-core'
require 'cocoapods'
require 'set'

$current_dir = File.dirname(File.expand_path(__FILE__)) 
$active_folder = $current_dir + "/../specs/"

@licenses = SortedSet.new
@numbers = {};

# Get the licenses + use count and order by popularity

def get_all_licenses pod_path
  
  begin 
    spec = eval( File.open(pod_path).read )

    if @licenses.include? spec.license[:type]
      @numbers[spec.license[:type]] = @numbers[spec.license[:type]] + 1
    else
      @licenses.add spec.license[:type]
      @numbers[spec.license[:type]] = 1
    end

  rescue Exception => e
  
  end
end

def get_all_licenses_done
  @numbers.sort_by {|_key, value| value}

  for key, value in @numbers
   puts value.to_s + " " + key
  end
end

@method = :get_all_licenses
@done = :get_all_licenses_done

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
