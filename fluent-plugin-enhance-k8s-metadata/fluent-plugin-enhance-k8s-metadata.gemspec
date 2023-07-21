lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name    = 'fluent-plugin-enhance-k8s-metadata'
  spec.version = '2.0.0'
  spec.authors = ['Sumo Logic']
  spec.email   = ['collection@sumologic.com']

  spec.summary       = 'Fluentd plugin for appending extra metadata from Kubernetes.'
  spec.homepage      = 'https://github.com/SumoLogic/sumologic-kubernetes-collection'
  spec.license       = 'Apache-2.0'

  spec.files         = Dir.glob(File.join('lib', '**', '*.rb'))
  spec.executables   = []
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'concurrent-ruby', '~> 1.1'
  spec.add_runtime_dependency "fluentd", "= 1.16.2"
  # spec.add_runtime_dependency 'kubeclient', '4.9.1' # Git version of Kubeclient specified in Gemfile
  spec.add_runtime_dependency 'lru_redux', '~> 1.1.0'
  spec.add_runtime_dependency 'net-http-persistent', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'test-unit', '~> 3.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
