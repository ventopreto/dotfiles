$LOAD_PATH.unshift("/home/vento/.asdf/installs/ruby/3.2.0/lib/ruby/gems/3.2.0/gems/amazing_print-1.8.1/lib")

IRB.conf[:USE_AUTOCOMPLETE] = true
IRB.conf[:USE_COLORIZE] = true
IRB.conf[:COLOR_THEME] = :dark
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:EDITOR] = 'code' # ou "vim", "nvim", etc.

begin
  require 'amazing_print'
  AmazingPrint.irb!
rescue LoadError
  puts '[.irbrc] amazing_print não encontrado'
end

# Comando customizado: cls
IRB::ExtendCommandBundle.module_eval do
  def cls
    system('clear')
  end
end