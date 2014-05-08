require 'cocoapods-core'
require 'cocoapods'
require 'set'

# recommend throwing into http://textmechanic.com/Sort-Text-Lines.html 
# then doing natural sort

module Pod
  class Specification

    def or_license_name_and_url
      if self.license.is_a? Hash
        license = self.license[:type].downcase
        
        # rule of thumb, if it can't get a good enough match for version, do wikipedia
        if license.scan(/mit/).count > 0
          return { :license => "MIT", :url => "http://opensource.org/licenses/MIT" }

        elsif license.scan(/apache license, version 2.0/).count > 0
          return { :license => "Apache 2", :url => "https://www.apache.org/licenses/LICENSE-2.0.html" }
        elsif license.scan(/apache 2.0/).count > 0
          return { :license => "Apache 2", :url => "https://www.apache.org/licenses/LICENSE-2.0.html" }
        elsif license.scan(/apache2/).count > 0
          return { :license => "Apache 2", :url => "https://www.apache.org/licenses/LICENSE-2.0.html" }

        elsif license.scan(/bsd 3/).count > 0
          return { :license => "BSD 3.0", :url => "http://opensource.org/licenses/BSD-3-Clause" }
        elsif license.scan(/new bsd/).count > 0
          return { :license => "BSD 3.0", :url => "http://opensource.org/licenses/BSD-3-Clause" }
        elsif license.scan(/bsd 2/).count > 0
          return { :license => "BSD 2.0", :url => "http://opensource.org/licenses/BSD-2-Clause" }
        elsif license.scan(/2-clause bsd/).count > 0
          return { :license => "BSD 2.0", :url => "http://opensource.org/licenses/BSD-2-Clause" }
        elsif license.scan(/bsd/).count > 0
          return { :license => "BSD", :url => "https://en.wikipedia.org/wiki/BSD_licenses" }
          
        elsif license.scan(/creative commons/).count > 0
          return { :license => "CC", :url => "https://creativecommons.org/licenses/" }
        elsif license.scan(/commercial/).count > 0
          return { :license => "Commercial", :url => self.homepage }
        elsif license.scan(/netbsd/).count > 0
          return { :license => "NetBSD", :url => "http://www.netbsd.org/about/redistribution.html" }

        elsif license.scan(/lgpl v3/).count > 0
          return { :license => "LGPL 3", :url => "http://opensource.org/licenses/lgpl-3.0.html" }
        elsif license.scan(/gpl v3/).count > 0
          return { :license => "GPL 3", :url => "http://opensource.org/licenses/gpl-3.0.html" }
        elsif license.scan(/gpl v3/).count > 0
          return { :license => "GPL 3", :url => "http://www.netbsd.org/about/redistribution.html" }
          
        elsif license.scan(/boost/).count > 0
          return { :license => "Boost", :url => "http://www.boost.org/users/license.html" }
        elsif license.scan(/eclipse/).count > 0
          return { :license => "eclipse", :url => "http://www.eclipse.org/legal/epl-v10.html" }
        elsif license.scan(/zlib/).count > 0
          return { :license => "zlib", :url => "http://opensource.org/licenses/Zlib" }
        elsif license.scan(/wtf/).count > 0
          return { :license => "WTFPL", :url => "http://www.wtfpl.net" }
        elsif license.scan(/eclipse/).count > 0
          return { :license => "eclipse", :url => "http://www.eclipse.org/legal/epl-v10.html" }
        end
      end
      
      return { :license => "Custom License", :url => self.homepage }
    end

  end
end


$current_dir = File.dirname(File.expand_path(__FILE__)) 
$active_folder = $current_dir + "/../specs/"

@licenses = SortedSet.new
@numbers = {};

# Get the licenses + use count and order by popularity

def get_all_licenses pod_path
  
  begin 
    spec = eval( File.open(pod_path).read )

    license = spec.license[:type]
    if @licenses.include? license
      @numbers[license] = @numbers[license] + 1
    else
      @licenses.add license
      @numbers[license] = 1
    end

  rescue Exception => e
  
  end
end

def get_all_cocoadocs_licenses pod_path
  
  begin 
    spec = eval( File.open(pod_path).read )
    
    license = spec.or_license_name_and_url
    if @licenses.include? license
      @numbers[license] = @numbers[license] + 1
    else
      @licenses.add license
      @numbers[license] = 1
    end

  rescue Exception => e
  
  end
end

def get_all_cocoadocs_licenses_done
  @numbers.sort_by {|_key, value| value}

  for key, value in @numbers
   puts value.to_s + " " + key[:license]
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

# cocoadocs stuff
@method = :get_all_cocoadocs_licenses
@done = :get_all_cocoadocs_licenses_done


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
