require 'log4r'

module VagrantPlugins
  module Lightsail
    module Action
      # This stops the running instance.
      class StopInstance
        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::stop_instance')
        end

        def call(env)
          if env[:machine].state.id == :stopped
            env[:ui].info I18n.t('vagrant_lightsail.already_status', status: env[:machine].state.id)
          else
            env[:ui].info(I18n.t('vagrant_lightsail.stopping'))
            env[:lightsail_client].stop_instance(instance_name: env[:machine].id)
          end

          @app.call(env)
        end
      end
    end
  end
end
