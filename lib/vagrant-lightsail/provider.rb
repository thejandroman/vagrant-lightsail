require 'vagrant'

module VagrantPlugins
  module Lightsail
    class Provider < Vagrant.plugin('2', :provider)
      def initialize(machine)
        @machine = machine
      end

      def action(name)
        return Action.send(name) if Action.respond_to?(name)
        nil
      end

      def ssh_info
        # Run a custom action called "read_ssh_info" which does what
        # it says and puts the resulting SSH info into the
        # `:machine_ssh_info` key in the environment.
        env = @machine.action('read_ssh_info', lock: false)
        env[:machine_ssh_info]
      end

      def state
        # Run a custom action called "read_state" which does what it
        # says and puts the state into the `:machine_state_id` key in
        # the environment.
        env = @machine.action('read_state', lock: false)

        state_id = env[:machine_state_id]

        # Get the short and long description
        short = I18n.t("vagrant_lightsail.states.short_#{state_id}")
        long  = I18n.t("vagrant_lightsail.states.long_#{state_id}")

        # Return the MachineState object
        Vagrant::MachineState.new(state_id, short, long)
      end
    end
  end
end
