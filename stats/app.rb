require 'cocoapods-core'
require 'cocoapods'
require 'set'

# $current_dir = File.dirname(File.expand_path(__FILE__)) 
# $active_folder = $current_dir + "/specs/"

$active_folder = "/Users/orta/spiel/ios/Specs"

@emails = []
@spec_metadata = []


# Find all the authors of specs with a commit instead of a tag

def get_commit_refs pod_path

  
  begin 
    spec = eval( File.open(pod_path).read )
    # if spec.version.version.to_s 
    if spec.source[:commit] && spec.source[:git] && (spec.version.to_s != "0.0.1")
      puts "adding #{spec.name}"
      @emails << spec.authors
      @spec_metadata << { :v => spec.version.to_s, :name => spec.name, :commit => spec.source[:commit] }
    end
        
  rescue Exception => e
#    p e
  end
end

def get_commit_refs_done
  puts "----------------------------"
  
  for authors in @emails
    for key, value in authors
      if key && value
        puts '"' + key + '" ' + value + ""  
      end
    end
  end
  
  puts ""
  
  for info in @spec_metadata
   puts  info[:name] + " - " + info[:v] + " (#{ info[:commit] })"
  end
    
end

@method = :get_commit_refs
@done = :get_commit_refs_done

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

