require 'cocoapods-core'
require 'cocoapods'
require 'set'

module Pod
  class Specification
    def or_is_github?
      homepage.include?("github.com") || (source[:git] && source[:git].include?("github.com"))
    end

    def or_github_url
      return homepage if homepage.include?("github.com")
      return source[:git] if source[:git] && source[:git].include?("github.com")
    end

    def or_user
      return nil unless self.or_is_github?
      or_github_url.split("/")[-2]
    end

    def or_repo
      return nil unless self.or_is_github?
      or_github_url.split("/")[-1].gsub(".git", "")
    end

    def or_github_repo
      "#{or_user}/#{or_repo}"
    end
  end
end

@repos = Set.new

def get_all_repos(spec)
  if spec.or_is_github?
    repo = spec.or_github_repo
    @repos.add repo
    puts repo
  end
end

def get_all_repos_done
  for key in @repo
   puts key
  end
end

@method = :get_all_repos
@done = :get_all_repos_done

config = Pod::Config.new()
source = Pod::Source.new(config.repos_dir + 'master')

source.all_specs.each do |spec|
  self.send @method, spec
end
