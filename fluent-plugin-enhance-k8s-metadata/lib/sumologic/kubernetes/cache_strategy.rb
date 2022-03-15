module SumoLogic
  module Kubernetes
    # module for caching strategy
    module CacheStrategy
      require 'lru_redux'
      require_relative 'reader.rb'

      def init_cache
        @cache = LruRedux::TTL::ThreadSafeCache.new(@cache_size, @cache_ttl)
      end

      def get_pod_metadata(namespace_name, pod_name)
        key = "#{namespace_name}::#{pod_name}"
        metadata = @cache[key]
        if metadata.nil?
          metadata = fetch_pod_metadata(namespace_name, pod_name)
          @cache[key] = metadata
        end
        metadata
      end

      def refresh_cache
        # Refresh the cache by re-fetching all the pod metadata.
        entries = @cache.to_a
        log.info "Refreshing metadata for #{entries.count} entries"

        entries.each { |key, _|
          begin
            refresh_cache_entry(key)
            # Adding friction to avoid aggressive refresh.
            if !@cache_refresh_apiserver_request_delay.nan? && !@cache_refresh_apiserver_request_delay.negative?
              sleep @cache_refresh_apiserver_request_delay
            end
          rescue => e
            log.error "Cannot refresh metadata for key #{key}: #{e}"
          end
        }
      end

      def refresh_cache_entry(cache_key)
        log.debug "Refreshing metadata for key #{cache_key}"
        namespace_name, pod_name = cache_key.split("::")
        if !@cache_refresh_exclude_pod_regex.to_s.strip.empty? && Regexp.compile(@cache_refresh_exclude_pod_regex).match(pod_name)
            log.debug "Deleted metadata for key #{cache_key}"
            @cache.delete(cache_key)
            return nil
        end
        metadata = fetch_pod_metadata(namespace_name, pod_name)
        if metadata.empty?
            # if the pod doesn't exist anymore, remove its key from the cache
            @cache.delete(cache_key)
        else
            @cache[cache_key] = metadata
        end
      end

    end
  end
end
