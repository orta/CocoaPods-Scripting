require 'date'

@stats = ["date, podspecs, versions, committer count"]
@orta = false;
@fabio = false;

def statify date
  spec_count = `ls | wc -l`.strip
  spec_versions = `ls -l -R | grep pod | wc -l`.strip
  committors = `git shortlog -s -n | wc -l`.strip
  orta = `git shortlog -s -n | grep Orta`.strip
  fabio = `git shortlog -s -n | grep Fabio`.strip
  @stats << "#{date}, #{spec_count}, #{spec_versions}, #{committors}"
  
  if @orta == false and orta.length
    @orta == true
    p "Orta at #{date}"
  end
  
  if @fabio == false and fabio.length
    @fabio == true
    p "Fabio at #{date}"
  end
  
end

first_date = Date::strptime("8-09-2011","%d-%m-%Y")
current_date = Date.today

unless Dir.exists? "Specs"
  `git clone https://github.com/CocoaPods/Specs.git`
end

Dir.chdir("Specs") do
  `git checkout master`
  
  while current_date > first_date
    current_date = current_date - 7

      `git stash`
      sha = `git rev-list -n 1 --before="#{current_date}" master`
      if sha
        `git checkout #{sha}`
        statify current_date
      
      else
        exit
      end
    end
end
 
for line in @stats
  p line
end