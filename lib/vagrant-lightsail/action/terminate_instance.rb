require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This terminates the running instance.
      class TerminateInstance
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::terminate_instance')
        end

        # Destroy the server and remove the tracking ID
        def call(env)
          env[:ui].info(I18n.t('vagrant_lightsail.terminating'))
          begin
            env[:lightsail_client].delete_instance(instance_name: env[:machine].id)
          rescue Aws::Lightsail::Errors => e
            raise Errors::LightailError, message: e
          end

          env[:machine].id = nil

          @app.call(env)
        end
      end
    end
  end
end
