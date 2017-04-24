#!/usr/bin/env ruby

require 'httparty'
require 'dotenv'
require 'json'
require_relative 'job'

Dotenv.load

class Main
  def main
    interesting_builds.map do |build_name|
      frontend_uri = "https://#{hostname}/job/#{build_name}/api/json"

      response = authenticated_request(frontend_uri)

      builds = response["builds"]

      latest_build = builds.sort_by { |build| build["number"] }.last

      [build_name, authenticated_request("#{latest_build["url"]}/api/json")]
    end
  end

  def all_builds
    frontend_uri = "https://#{hostname}/api/json"

    response = authenticated_request(frontend_uri)

    jobs = response['jobs'].map do |job|
      Job.new(job["name"], job["color"])
    end

    jobs.to_json
  end

  private

  def authenticated_request(uri)
    response = HTTParty.get(uri, basic_auth: {
      username: ENV.fetch("JENKINS_USER"),
      password: ENV.fetch("JENKINS_TOKEN")
    })

    JSON.parse(response.body)
  end

  def interesting_builds
    ENV.fetch("JENKINS_BUILDS").split(",").map(&:strip)
  end

  def hostname
    ENV.fetch("JENKINS_HOSTNAME").strip
  end
end

puts "All builds"
puts Main.new.all_builds

puts
puts "Interesting builds - retrieved per build"
interesting_builds = Main.new.main.map do |build_name, response|
  "#{build_name} -> #{response["result"]}"
end

puts interesting_builds
