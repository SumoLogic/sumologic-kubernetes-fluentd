lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-events"
  spec.version = "2.0.0"
  spec.authors = ["Sumo Logic"]
  spec.email   = ["collection@sumologic.com"]

  spec.summary       = %q{Fluentd input plugin for watching kubernetes events.}
  spec.homepage      = "https://github.com/SumoLogic/sumologic-kubernetes-collection"
  spec.license       = "Apache-2.0"

  spec.files         = Dir.glob(File.join('lib', '**', '*.rb'))
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "fluentd", [">= 0.14.10", "< 2"]
  spec.add_runtime_dependency 'kubeclient', '4.9.1'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.add_development_dependency 'mocha'
end
