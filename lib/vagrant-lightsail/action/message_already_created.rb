module VagrantPlugins
  module Lightsail
    module Action
      class MessageAlreadyCreated
        def initialize(app, _)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_lightsail.already_status', status: 'created'))
          @app.call(env)
        end
      end
    end
  end
end
