require 'test/unit'

class TestDocker < Test::Unit::TestCase
  CONTAINER_NAME = 'test-container'.freeze
  DUMMY_OUTPUT = 'dummy: {"hello":"world"}'.freeze

  def setup
    system("docker rm -f #{CONTAINER_NAME}", out: File::NULL, err: File::NULL)
  end

  def teardown
    system("docker rm -f #{CONTAINER_NAME}", out: File::NULL, err: File::NULL)
  end

  def docker_tag
    ENV['DOCKER_TAG'].nil? ? 'kubernetes-fluentd' : ENV['DOCKER_TAG']
  end

  def test_docker_image_exist
    result = `docker images`
    assert result.include?(docker_tag)
  end

  def test_docker_image_runnable
    id = `docker run -d --rm --name #{CONTAINER_NAME} #{docker_tag}:latest`
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
