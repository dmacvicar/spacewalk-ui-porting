require 'spacewalk_html_clean/commands'

module SpacewalkHtmlClean

  class MainCommand < Clamp::Command

    subcmds = SpacewalkHtmlClean::Commands.constants.map do |c|
      SpacewalkHtmlClean::Commands.const_get(c)
    end.select {|c| c.is_a?(Class)}

    subcmds.each do |subcmd|
      subcommand subcmd.command_name, "lalal", subcmd
    end
  end
end