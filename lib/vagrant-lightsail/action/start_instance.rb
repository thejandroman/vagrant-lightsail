require 'log4r'
require 'vagrant/util/retryable'

module VagrantPlugins
  module Lightsail
    module Action
      # This starts a stopped instance.
      class StartInstance
        include Vagrant::Util::Retryable

        def initialize(app, _)
          @app    = app
          @logger = Log4r::Logger.new('vagrant_lightsail::action::start_instance')
        end

        def call(env)
          env[:ui].info I18n.t 'vagrant_lightsail.starting'

          begin
            env[:lightsail_client].start_instance(instance_name: env[:machine].id).operations[0]
          rescue Aws::Lightsail::Errors => e
            raise Errors::LightailError, message: e
          end

          retryable(tries: 120, sleep: 10) do
            break if env[:interrupted]
            env[:ui].info I18n.t 'vagrant_lightsail.waiting_for_ssh'
            raise 'not ready' unless env[:machine].communicate.ready?
          end

          env[:ui].info I18n.t('vagrant_lightsail.ready')

          @app.call env
        end
      end
    end
  end
end
