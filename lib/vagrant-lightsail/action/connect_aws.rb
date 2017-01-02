require 'aws-sdk'
require 'log4r'

module VagrantPlugins
  module LightSail
    module Action
      # This action connects to AWS, verifies credentials work, and
      # puts the AWS connection object into the `:aws_compute` key
      # in the environment.
      class ConnectLightsail
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::connect_lightsail')
        end

        def call(env)
          aws_sdk_config = {
            aws_access_key_id: env[:machine].provider_config.access_key_id,
            aws_secret_access_key: env[:machine].provider_config.secret_access_key,
            aws_session_token: env[:machine].provider_config.session_token,
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
