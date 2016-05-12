require 'net/http'
require 'uri'
require 'json'

# Helper class for creating and destroying Marathon Apps using the REST API.
class Marathon
  # Apps need to be started in this order.
  MARATHON_APPS = ['remainder', 'producer', 'consumer', 'microscaling']

  # Template variables
  USER_ID_VAR = '__MSS_USER_ID__'
  MICROSCALING_API_VAR = '__MSS_API_ADDRESS__'
  MARATHON_API_VAR = '__MSS_MARATHON_API__'
  AZURE_STORAGE_ACCOUNT_NAME = '__AZURE_STORAGE_ACCOUNT_NAME__'
  AZURE_STORAGE_ACCOUNT_KEY = '__AZURE_STORAGE_ACCOUNT_KEY__'
  AZURE_STORAGE_QUEUE_NAME = '__AZURE_STORAGE_QUEUE_NAME__'

  # Default values if environment variables are not set.
  DEFAULTS = {
    'MSS_API_ADDRESS' => 'app.microscaling.com:8000'
  }

  # Create the Marathon Apps needed for the demo using the REST API.
  def self.create_apps
    marathon_api = env_or_error('MSS_MARATHON_API')

    # Remainder uses the spare capacity on the cluster.
    create_app(marathon_api, 'remainder')

    # Producer and Consumer add and remove items from the Azure Storage Queue.
    create_azure_queue_app(marathon_api, 'producer')
    create_azure_queue_app(marathon_api,'consumer')

    # Microscaling Engine app scales the demo.
    create_microscaling_app(marathon_api)
  end

  # Deletes the demo apps from Marathon using the REST API.
  def self.delete_apps
    marathon_api = env_or_error('MSS_MARATHON_API')

    MARATHON_APPS.each do |app_name|
      delete_app(marathon_api, app_name) if app_exists?(marathon_api, app_name)
    end
  end

private
  # Creates the Microscaling Engine app that scales the demo.
  def self.create_microscaling_app(marathon_api)
    app_name = 'microscaling'
    app_json = load_config(app_name)

    # Get leader from the API in case we're connecting over a SSH tunnel.
    leader_api = get_leader(marathon_api)

    # Microscaling settings.
    user_id = env_or_error('MSS_USER_ID')
    microscaling_api = env_or_default('MSS_API_ADDRESS')

    app_json = replace_var(app_json, USER_ID_VAR, user_id)
    app_json = replace_var(app_json, MICROSCALING_API_VAR, microscaling_api)
    app_json = replace_var(app_json, MARATHON_API_VAR, leader_api)

    # Azure Storage keys for accessing the queue length.
    account_name = env_or_error('AZURE_STORAGE_ACCOUNT_NAME')
    account_key = env_or_error('AZURE_STORAGE_ACCOUNT_KEY')

    app_json = replace_var(app_json, AZURE_STORAGE_ACCOUNT_NAME, account_name)
    app_json = replace_var(app_json, AZURE_STORAGE_ACCOUNT_KEY, account_key)

    create_app(marathon_api, app_name, app_json)
  end

  # Creates the producer and consumer apps with the Azure Storage Queue settings.
  def self.create_azure_queue_app(marathon_api, app_name)
    account_name = env_or_error('AZURE_STORAGE_ACCOUNT_NAME')
    account_key = env_or_error('AZURE_STORAGE_ACCOUNT_KEY')
    queue_name = env_or_error('AZURE_STORAGE_QUEUE_NAME')

    app_json = load_config(app_name)
    app_json = replace_var(app_json, AZURE_STORAGE_ACCOUNT_NAME, account_name)
    app_json = replace_var(app_json, AZURE_STORAGE_ACCOUNT_KEY, account_key)
    app_json = replace_var(app_json, AZURE_STORAGE_QUEUE_NAME, queue_name)

    create_app(marathon_api, app_name, app_json)
  end

  # Create a Marathon App using the REST API.
  def self.create_app(marathon_api, app_name, app_json = nil)
    # Check if app exists before creating it.
    unless app_exists?(marathon_api, app_name)
      app_json = load_config(app_name) if app_json.nil?
      uri = URI.parse(marathon_api + '/v2/apps/')

      http = Net::HTTP.new(uri.host, uri.port)
      req = Net::HTTP::Post.new(uri.request_uri,
                                    initheader = { 'Content-Type' => 'application/json' })
      req.body = app_json
      resp = http.request(req)

      puts "Created #{app_name} app"
    end
  end

  # Delete a Marathon App using the REST API.
  def self.delete_app(marathon_api, app_name)
    uri = URI.parse(marathon_api + '/v2/apps/' + app_name)

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Delete.new(uri.path,
                                initheader = { 'Content-Type' => 'application/json' })
    resp = http.request(req)

    puts "Deleted #{app_name} app"
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

  # Gets the current leader from the REST API.
  def self.get_leader(marathon_api)
    uri = URI.parse(marathon_api + '/v2/leader/')

    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Get.new(uri.path,
                                initheader = { 'Content-Type' => 'application/json' })
    resp = http.request(req)
    data = JSON.parse(resp.body)

    data['leader']
  end

  # Replace a variable in the App JSON template.
  def self.replace_var(config_json, var_name, value)
    config_json.gsub(var_name, value)
  end

  # Load the App JSON as a string.
  def self.load_config(app_name)
    IO.read(File.join(File.dirname(__FILE__), 'marathon_apps', "#{app_name}.json"))
  end

  # Get environment variable if set or return the default.
  def self.env_or_default(var_name)
    if ENV.has_key?(var_name)
      result = ENV[var_name]
    else
      result = DEFAULTS[var_name]
    end
  end

  # Get environment variable or error if it is not set.
  def self.env_or_error(var_name)
    if ENV.has_key?(var_name)
      result = ENV[var_name]
    else
      raise("Must provide environment variable '#{var_name}'")
    end
  end
end
