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
  dom.entity :pods, :pod, 'pods'
  dom.entity :cocoadocs_pod_metrics, :cocoadocs_pod_metric, 'cocoadocs_pod_metrics'
end

# Generate easy accessors
DB.entities.each do |entity|
  name = entity.plural
  define_method name do
    DB[name]
  end
end

# Loop through all Pods
source = Pod::Source.new("#{ENV['HOME']}/.cocoapods/repos/master")
source.pod_sets.each do |spec_set|

  # Grab latest spec for rendering description
  spec_path = spec_set.highest_version_spec_path
  spec = Pod::Specification.from_file(spec_path)

  # Find it in trunk db
  pod = pods.where(pods[:name] => spec_set.name).first
  next unless pod

  # Look CD metric to append to
  metric = cocoadocs_pod_metrics.where(cocoadocs_pod_metrics[:pod_id] => pod.id).first
  next unless metric

  puts "Updating #{spec_set.name}"
  cocoadocs_pod_metrics.update( "rendered_summary" => spec.or_summary_html ).where(id: metric.id)
end
