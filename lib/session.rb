# frozen_string_literal: true

# rubocop:disable Metrics/AbcSize,Lint/MissingCopEnableDirective

module AutoHCK
  class Session
    extend T::Sig
    include Helper

    def self.save(workspace_path, options)
      File.write("#{workspace_path}/session.json", compose_session_json(options, workspace_path))
    end

    def self.load(cli)
      session = Models::Session.from_json_file("#{session_path(cli)}/session.json")

      backup_cli = cli.clone
      cli.test = session.test
      cli.common = session.common

      cli.test.manual ||= true

      cli.test.session = session_path(backup_cli)
      cli.test.latest_session = backup_cli.test.latest_session
      cli.common.workspace_path = backup_cli.common.workspace_path
    end

    def self.session_path(cli)
      cli.test.latest_session ? "#{Config.read['workspace_path']}/latest" : cli.test.session
    end

    private_class_method def self.compose_session_json(options, workspace_path)
      session = AutoHCK::Models::Session.new(
        test: options.test,
        common: options.common
      )
      session.common.workspace_path = workspace_path
      session.as_json
    end
  end
end
