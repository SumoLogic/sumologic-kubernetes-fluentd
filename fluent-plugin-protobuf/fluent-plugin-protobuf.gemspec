lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = "fluent-plugin-protobuf"
  spec.version = "2.0.0"
  spec.authors = ["Sumo Logic"]
  spec.email   = ["collection@sumologic.com"]

  spec.summary       = %q{Fluentd plugin for parsing protobuf payload.}
  spec.homepage      = "https://github.com/SumoLogic/sumologic-kubernetes-collection"
  spec.license       = "Apache-2.0"

  spec.files         = Dir.glob(File.join('lib', '**', '*.rb'))
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "test-unit", "~> 3.0"
  spec.add_runtime_dependency "google-protobuf", ">= 3.17", "< 5.0"
  spec.add_runtime_dependency "snappy", "> 0"
  spec.add_runtime_dependency "fluentd", "= 1.16.5"
end
