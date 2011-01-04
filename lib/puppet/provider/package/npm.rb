require 'puppet/provider/package'

Puppet::Type.type(:package).provide :npm, :parent => Puppet::Provider::Package do
  desc "node.js package management with npm"

  commands :npm_cmd => "/usr/local/bin/npm"

  def install
    output = npm_cmd :install, @resource[:name]

  end

  def uninstall
  end
    
end

