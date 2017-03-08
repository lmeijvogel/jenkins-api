require 'httparty'
require 'dotenv'
require 'json'

Dotenv.load

def hostname
  ENV.fetch("JENKINS_HOSTNAME").strip
end

def main
   # Heavy request,  but it collects all build statuses as well
  frontend_uri = "https://#{hostname}/job/Frontend/api/json?depth=1"

  response = authenticated_request(frontend_uri)

  builds = response["builds"]

  p builds.last
end

def authenticated_request(uri)
  response = HTTParty.get(uri, basic_auth: {
    username: ENV.fetch("JENKINS_USER"),
    password: ENV.fetch("JENKINS_TOKEN")
  })

  JSON.parse(response.body)
end

main
