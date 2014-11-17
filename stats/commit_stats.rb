require 'date'

@stats = ["date, podspecs, versions, committer count"]

def statify date
  spec_count = `ls Specs | wc -l`.strip
  spec_versions = `ls -l -R | grep pod | wc -l`.strip
  committors = `git shortlog -s -n | wc -l`.strip
  @stats << "#{date}, #{spec_count}, #{spec_versions}, #{committors}"
end

first_date = Date::strptime("01-05-2014","%d-%m-%Y")
current_date = Date.today

Dir.chdir("../Specs") do
  # `git checkout master`
  
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