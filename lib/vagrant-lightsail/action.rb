require 'vagrant-lightsail/action/connect_lightsail'
require 'vagrant-lightsail/action/read_ssh_info'
require 'vagrant-lightsail/action/read_state'

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
    end
  end
end
