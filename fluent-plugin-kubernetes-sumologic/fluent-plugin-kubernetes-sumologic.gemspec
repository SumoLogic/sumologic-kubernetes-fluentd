# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-kubernetes-sumologic"
  spec.version       = "2.0.0"
  spec.authors       = ["Sumo Logic"]
  spec.email         = ["collection@sumologic.com"]
  spec.description   = %q{FluentD plugin to enrich logs with Sumo Logic specific metadata.}
  spec.summary       = %q{FluentD plugin to enrich logs with Sumo Logic specific metadata.}
  spec.homepage      = "https://github.com/SumoLogic/sumologic-kubernetes-collection"
  spec.license       = "Apache-2.0"

  spec.files         = Dir.glob(File.join('lib', '**', '*.rb'))
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_development_dependency "bundler", "~> 2"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'test-unit', '~> 3.4.0'
  spec.add_development_dependency "codecov", ">= 0.1.10"
  spec.add_runtime_dependency "fluentd", "= 1.14.5"
  spec.add_runtime_dependency 'httpclient', '~> 2.8.0'
end
