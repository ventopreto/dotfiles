$LOAD_PATH.unshift("/home/vento/.asdf/installs/ruby/3.2.0/lib/ruby/gems/3.2.0/gems/pry-theme-1.3.1/lib")
$LOAD_PATH.unshift("/home/vento/.asdf/installs/ruby/3.2.0/lib/ruby/gems/3.2.0/gems/amazing_print-1.8.1/lib")

require 'pry-theme'

# === EDITOR ===

Pry.editor = 'code' # 'vi', 'subl

Pry.config.prompt = Pry::Prompt[:rails] if Pry::Prompt[:rails]
# == Pry-Nav - Using pry as a debugger ==
begin
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'l', 'whereami'
rescue StandardError
  nil
end

Pry::Commands.block_command 'p', 'Print in colors' do |x|
  Pry::ColorPrinter.pp(x)
end

Pry.config.print = proc { |output, value|
  puts "Chamando printer com output: #{output.inspect}"
  Pry::ColorPrinter.pp(value, output || $stdout)
}

unless ENV['PRY_BW']
  Pry.color = true
  Pry.config.theme = 'tomorrow'
  Pry.config.prompt = PryRails::RAILS_PROMPT if defined?(PryRails::RAILS_PROMPT)
  Pry.config.prompt ||= Pry.prompt
end

begin
  require 'amazing_print'
  AmazingPrint.pry!

  AmazingPrint::Formatter.class_eval do
    def format_nkdimensa_httpresponse(object)
      {
        status_code: object.status_code,
        response: object.response,
        errors: object.errors
      }.ai
    end
  end
rescue LoadError => e
  begin
    require 'amazing_print'
    AmazingPrint.pry!
  rescue LoadError => err2
  end
end

Pry.config.pager = false

Pry.config.history_file = '~/.pry_history'
Pry.config.history_save = true
Pry::Commands.command(/^$/, 'repeat last command') do
  _pry_instance_ Pry.history.to_a.last
end

Pry.config.ls.separator = "\n" # new lines between methods
Pry.config.ls.heading_color = :magenta
Pry.config.ls.public_method_color = :green
Pry.config.ls.protected_method_color = :yellow
Pry.config.ls.private_method_color = :bright_black

Pry::Commands.create_command "p" do
  description "Prints using Pry::ColorPrinter"

  def process
    Pry::ColorPrinter.pp(target, output)
  end
end