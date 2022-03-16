require 'helper'
require 'sumologic/kubernetes/cache_strategy.rb'
require 'fluent/test/log'

class CacheStrategyTest < Test::Unit::TestCase
  include SumoLogic::Kubernetes::Connector
  include SumoLogic::Kubernetes::Reader
  include SumoLogic::Kubernetes::CacheStrategy

  def setup
    # runs before each test
    stub_apis
    connect_kubernetes
    init_cache
  end

  def teardown
    # runs after each test
  end

  def log
    Fluent::Test::TestLogger.new
  end

  test 'get_pod_metadata load labels from API' do
    metadata = get_pod_metadata('sumologic', 'somepod')
    assert_not_nil metadata
    assert_equal '1691804713', metadata['pod_labels']['pod_labels']['pod-template-hash']
    assert_equal 'curl-byi', metadata['pod_labels']['pod_labels']['run']
  end

  test 'get_pod_metadata load labels from cache if already exist' do
    assert_not_nil @cache
    @cache['sumologic::somepod'] = {
      'pod_labels' => {
        'pod_labels' => {
          'pod-template-hash' => '0',
          'run' => 'from-cache'
        }
      }
    }
    metadata = get_pod_metadata('sumologic', 'somepod')
    assert_equal '0', metadata['pod_labels']['pod_labels']['pod-template-hash']
    assert_equal 'from-cache', metadata['pod_labels']['pod_labels']['run']
  end

  test 'get_pod_metadata cache empty result' do
    assert_not_nil @cache
    @cache['sumologic::somepod'] = {}
    metadata = get_pod_metadata('sumologic', 'somepod')
    assert_not_nil metadata
    assert_equal 0, metadata.size
  end
  
  test 'refreshing cache entry deletes it if no metadata' do
    stub_request(:get, %r{/api/v1/namespaces/namespace/pods/non_existent})
        .to_raise(Kubeclient::ResourceNotFoundError.new(404, nil, nil))
    key = 'namespace::non_existent'
    @cache[key] = {}
    refresh_cache_entry(key)
    assert_false @cache.key?(key)
  end

  test 'refreshing cache entry deletes if part of exclude pod regex' do
    @cache_refresh_exclude_pod_regex = '(command-[a-z0-9]*|task-[a-z0-9]*)'
    key = 'namespace::command-3eu1ed-sfdfd'
    @cache[key] = {}
    refresh_cache_entry(key)
    assert_false @cache.key?(key)
  end

  test 'refreshing cache entry does not delete metadata if not part of regex' do
    stub_request(:get, %r{/api/v1/namespaces/sumologic/pods/pod-with-metadata})
        .to_return(body: test_resource('pod-with-metadata.json'), status: 200)
    @cache_refresh_exclude_pod_regex = '(command-[a-z0-9]*|task-[a-z0-9]*)'
    key = 'sumologic::pod-with-metadata'
    @cache[key] = {}
    refresh_cache_entry(key)
    assert_true @cache.key?(key)
  end

end
