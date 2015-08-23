require 'cocoapods'
require 'redcarpet'
require "awesome_print"

require 'flounder'
require 'data_objects'

# Extension from CocoaDocs

module Pod
  class Specification
    def or_summary_html
      original_text = description || summary
      renderer = Redcarpet::Render::HTML.new(filter_html: true, safe_links_only: true)
      markdown = Redcarpet::Markdown.new(renderer)
      markdown.render(original_text).strip
    end
  end
end

# Handle DB setup

options = {}
uri = DataObjects::URI::parse(ENV['DATABASE_URL'])
[:host, :port, :user, :password].each do |key|
  val = uri.send(key)
  options[key] = val if val
end
options[:dbname] = uri.path[1..-1]

# Connect.
connection = Flounder.connect options

# Setup tables
DB = Flounder.domain connection do |dom|
  # Trunk
  dom.entity :pods, :pod, 'pods'

  # CocoaDocs
  dom.entity :cocoadocs_pod_metrics, :cocoadocs_pod_metric, 'cocoadocs_pod_metrics'
  dom.entity :commits, :commit, 'commits'
  dom.entity :pod_versions, :pod_version, 'pod_versions'
end

# Generate easy accessors
DB.entities.each do |entity|
  name = entity.plural
  define_method name do
    DB[name]
  end
end

missed = 0

# Loop through all Pods
pods.where(deleted: false).each do |result|

  # Grab latest spec for rendering description
  version = pod_versions.where(pod_id: result["id"]).sort_by { |v| Pod::Version.new(v.name) }.last
  commit = commits.where(pod_version_id: version.id, deleted_file_during_import: false).first

  unless commit
    puts "\nSkipping #{result["name"]} cause of no commit data in db."
    missed += 1
    next
  end

  spec = Pod::Specification.from_json commit.specification_data

  # Look up CD metric to append to
  metric = cocoadocs_pod_metrics.where(cocoadocs_pod_metrics[:pod_id] => result["id"]).first
  unless metric
    puts "\nSkipping #{spec.name} cause of no metrics in db."
    missed += 1
    next
  end

  summary = spec.or_summary_html.gsub(/\0/, '')
  puts "Updating: #{result["name"]}"
  cocoadocs_pod_metrics.update( "rendered_summary" => summary ).where(id: metric.id).kick.first
end
