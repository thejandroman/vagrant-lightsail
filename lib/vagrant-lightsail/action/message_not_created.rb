module VagrantPlugins
  module Lightsail
    module Action
      class MessageNotCreated
        def initialize(app, _)
          @app = app
        end

        def call(env)
          env[:ui].info(I18n.t('vagrant_lightsail.not_created'))
          @app.call(env)
        end
      end
    end
  end
end
