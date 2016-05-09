require 'net/http'
require 'uri'

# Helper class for creating and destroying Marathon Apps using the REST API.
class Marathon
  MARATHON_APPS = ['consumer', 'producer', 'queue', 'remainder']

  # Template variables for microscaling.json
  USER_ID_VAR = '__MSS_USER_ID__'
  MICROSCALING_API_VAR = '__MSS_API_ADDRESS__'
  MARATHON_API_VAR = '__MSS_MARATHON_API__'

  # Create the Marathon Apps needed for the demo using the REST API.
  def self.create_apps(user_id, microscaling_api, marathon_api)
    create_microscaling_app(user_id, microscaling_api, marathon_api)

    MARATHON_APPS.each do |app_name|
      create_app(marathon_api, app_name) unless app_exists?(marathon_api, app_name)
    end
  end

  # Deletes the demo apps from Marathon using the REST API.
  def self.destroy_apps(marathon_api)
    destroy_app(marathon_api, 'microscaling')

    MARATHON_APPS.each do |app_name|
      destroy_app(marathon_api, app_name) if app_exists?(marathon_api, app_name)
    end
  end

private
  # Creates the Microscaling agent app. The environment variables provided
  # by the user are substituted into the template.
  def self.create_microscaling_app(user_id, microscaling_api, marathon_api)
    app_name = 'microscaling'
    app_json = load_config(app_name)

    app_json = replace_var(app_json, USER_ID_VAR, user_id)
    app_json = replace_var(app_json, MICROSCALING_API_VAR, microscaling_api)
    app_json = replace_var(app_json, MARATHON_API_VAR, marathon_api)

    create_app(marathon_api, app_name, app_json)
  end

  # Create a Marathon App using the REST API.
  def self.create_app(marathon_api, app_name, app_json = nil)
    app_json = load_config(app_name) if app_json.nil?
    uri = URI.parse(marathon_api + '/v2/apps/')

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Post.new(uri.request_uri,
                                  initheader = { 'Content-Type' => 'application/json' })
    req.body = app_json
    resp = http.request(req)
  end

  # Delete a Marathon App using the REST API.
  def self.destroy_app(marathon_api, app_name)
    uri = URI.parse(marathon_api + '/v2/apps/' + app_name)

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Delete.new(uri.path,
                                initheader = { 'Content-Type' => 'application/json' })
    resp = http.request(req)
  end

  # Checks whether the app exists by calling the Marathon API.
  def self.app_exists?(marathon_api, app_name)
    apps = []

    uri = URI.parse(marathon_api + '/v2/apps/')
    resp = Net::HTTP.get_response(uri)

    if resp.is_a?(Net::HTTPSuccess)
      data = JSON.parse(resp.body)

      # Get app names by removing leading slash from app ids.
      data['apps'].each do |app|
        apps.push(app['id'].gsub('/', ''))
      end
    end

    apps.include?(app_name)
  end

  # Replace a variable in the App JSON template.
  def self.replace_var(config_json, var_name, value)
    config_json.gsub(var_name, value)
  end

  # Load the App JSON as a string.
  def self.load_config(app_name)
    IO.read(File.join(File.dirname(__FILE__), 'marathon', "#{app_name}.json"))
  end
end
