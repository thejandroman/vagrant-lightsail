module VagrantPlugins
  module Lightsail
    module Action
      include Vagrant::Action::Builtin

      # This action is called to read the SSH info of the machine. The
      # resulting state is expected to be put into the
      # `:machine_ssh_info` key.
      def self.read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectLightsail
          b.use ReadSSHInfo
        end
      end

      # This action is called to read the state of the machine. The
      # resulting state is expected to be put into the
      # `:machine_state_id` key.
      def self.read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectLightsail
          b.use ReadState
        end
      end

      # This action is called to bring the box up from nothing.
      def self.up
        Vagrant::Action::Builder.new.tap do |b|
          b.use HandleBox
          b.use ConfigValidate
          b.use BoxCheckOutdated
          b.use ConnectLightsail
          b.use Call, IsCreated do |env1, b1|
            if env1[:result]
              b1.use Call, IsStopped do |env2, b2|
                if env2[:result]
                  b2.use prepare_boot
                  b2.use StartInstance # restart this instance
                  b2.use ConfigurePorts
                else
                  b2.use MessageAlreadyCreated # TODO: write a better message
                end
              end
            else
              b1.use SetupKey
              b1.use prepare_boot
              b1.use RunInstance # launch a new instance
              b1.use ConfigurePorts
            end
          end
        end
      end

      def self.prepare_boot
        Vagrant::Action::Builder.new.tap do |b|
          b.use Provision
          b.use SyncedFolders
        end
      end

      # This action is called to terminate the remote machine.
      def self.destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, DestroyConfirm do |env, b2|
            if env[:result]
              b2.use ConfigValidate
              b2.use Call, IsCreated do |env2, b3|
                unless env2[:result]
                  b3.use MessageNotCreated
                  next
                end

                b3.use ConnectLightsail
                b3.use ProvisionerCleanup, :before if defined? ProvisionerCleanup
                b3.use TerminateInstance
              end
            else
              b2.use MessageWillNotDestroy
            end
          end
        end
      end

      # This action is called when `vagrant provision` is called.
      def self.provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use Provision
          end
        end
      end

      def self.reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectLightsail
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use halt
            b2.use up
          end
        end
      end

      # This action is called to halt the remote machine.
      def self.halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use ConnectLightsail
            b2.use StopInstance
            b2.use WaitForState, :stopped, 120
          end
        end
      end

      # This action is called to SSH into the machine.
      def self.ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use Call, IsCreated do |env, b2|
            unless env[:result]
              b2.use MessageNotCreated
              next
            end

            b2.use SSHExec
          end
        end
      end

      # The autload farm
      action_root = Pathname.new(File.expand_path('action', __dir__))
      autoload :ConfigurePorts, action_root.join('configure_ports')
      autoload :ConnectLightsail, action_root.join('connect_lightsail')
      autoload :IsCreated, action_root.join('is_created')
      autoload :IsStopped, action_root.join('is_stopped')
      autoload :MessageAlreadyCreated, action_root.join('message_already_created')
      autoload :MessageNotCreated, action_root.join('message_not_created')
      autoload :MessageWillNotDestroy, action_root.join('message_will_not_destroy')
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
      autoload :ReadState, action_root.join('read_state')
      autoload :RunInstance, action_root.join('run_instance')
      autoload :SetupKey, action_root.join('setup_key')
      autoload :StartInstance, action_root.join('start_instance')
      autoload :StopInstance, action_root.join('stop_instance')
      autoload :TerminateInstance, action_root.join('terminate_instance')
      autoload :WaitForState, action_root.join('wait_for_state')
    end
  end
end
