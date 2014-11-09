# encoding utf-8

require 'uri'

module Browser
  def self.open uri
    uri = URI.parse uri.to_s
    unless uri.scheme
      raise ArgumentError, "no scheme given: #{uri}"
    end
    unless %w[http https ftp].include? uri.scheme
      raise ArgumentError, "invalid scheme: '#{uri.scheme}'"
    end
    case RUBY_PLATFORM
    when /mswin(?!ce) | mingw | bccwin/x
      system "start /B #{uri}"
    when /cygwin/
      system "cmd /C start /B #{uri}"
    when /darwin/
      system "open '#{uri}'"
    when /linux/
      system "xdg-open '#{uri}'"
    when /java/
      require 'java'
      import 'java.awt.Desktop'
      import 'java.net.URI'
      Desktop.getDesktop.browse java.net.URI.new uri
    else
      raise NotImplementedError
    end
  end
end

if $0 == __FILE__
  Browser.open(ARGV[0] || 'http://example.com/')
end
