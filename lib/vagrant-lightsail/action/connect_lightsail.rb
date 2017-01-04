require 'aws-sdk'
require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This action connects to Lightsail, verifies credentials work,
      # and puts the Lightsail connection object into the
      # `:lightsail_client` key in the environment.
      class ConnectLightsail
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::connect_lightsail')
        end

        def call(env)
          aws_sdk_config = {
            access_key_id: env[:machine].provider_config.access_key_id,
            secret_access_key: env[:machine].provider_config.secret_access_key,
            session_token: env[:machine].provider_config.session_token,
            region: env[:machine].provider_config.region
          }
          aws_sdk_config[:endpoint] = env[:machine].provider_config.endpoint if env[:machine].provider_config.endpoint

          @logger.info('Connecting to AWS Lightsail...')
          env[:lightsail_client] = Aws::Lightsail::Client.new(aws_sdk_config)

          @app.call(env)
        end
      end
    end
  end
end
