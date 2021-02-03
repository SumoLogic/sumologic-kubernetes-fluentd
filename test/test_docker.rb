require 'test/unit'

class TestDocker < Test::Unit::TestCase
  CONTAINER_NAME = 'test-container'.freeze
  DUMMY_OUTPUT = 'dummy: {"hello":"world"}'.freeze
  MOUNT_FLAGS = '-v $(pwd)/test/:/fluentd/etc'.freeze

  def setup
    system("docker rm -f #{CONTAINER_NAME}", out: File::NULL, err: File::NULL)
  end

  def teardown
    system("docker rm -f #{CONTAINER_NAME}", out: File::NULL, err: File::NULL)
  end

  def image_name
    ENV['IMAGE_NAME'].nil? ? 'kubernetes-fluentd:latest' : ENV['IMAGE_NAME']
  end

  def test_docker_image_exist
    puts "Testing image '#{image_name}'"
    result = `docker images --format "{{.Repository}}:{{.Tag}}"`
    assert result.include?(image_name)
  end

  def test_docker_image_runnable
    id = `docker run -d --rm #{MOUNT_FLAGS} --name #{CONTAINER_NAME} #{image_name}`
    assert !id.nil? && !id.empty?

    for _ in 1..15 do
      result = `docker ps --filter "name=#{CONTAINER_NAME}"`
      if !result.include?(CONTAINER_NAME)
        next
      end

      logs = `docker logs #{CONTAINER_NAME}`
      if logs.include?(DUMMY_OUTPUT)
        puts
        puts logs
        return
      end

      sleep 1
    end

    assert(false, "#{CONTAINER_NAME} didn't return expected output")
  end
end
