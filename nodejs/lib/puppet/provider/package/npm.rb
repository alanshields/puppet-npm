
require 'puppet/provider/package'

Puppet::Type.type(:package).provide :npm, :parent => Puppet::Provider::Package do
  desc "node.js package management with npm"

  commands :npm_cmd => "/home/node/opt/bin/npm"
  raise Puppet::Error, "The npm provider can only be used as root" if Process.euid != 0

  def self.npm_list(hash) 
    begin
      s = `sudo -u node -b sh -c \"export PATH=/home/node/opt/bin:${PATH}; cd /home/node; npm ls installed\"`
      list = s.split("\n").collect do |set|
        if npm_hash = npm_split(set)
          npm_hash[:provider] = :npm
          if npm_hash[:name] == hash[:justme]
            npm_hash
          elsif hash[:local]
            npm_hash
          else
            nil
          end
        else
          nil
        end
      end.compact
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list npm packages: #{detail}"
    end
    if hash[:local]
      list
    else
      list.shift
    end
  end

  def self.npm_split(desc)
    split_desc = desc.split(/ /)
    installed = split_desc[0]
    name = installed.split(/@/)[0]
    version = installed.split(/@/)[1]
    if (name.nil? || version.nil?)
      Puppet.warning "Could not match #{desc}"
      nil
    else
      return {
        :name => name,
        :ensure => version
      }
    end
  end

  def self.instances
    npm_list(:local => true).collect do |hash|
      new(hash)
    end
  end

  def install
    output = `sudo -u node -b sh -c "export PATH=/home/node/opt/bin:${PATH}; cd /home/node; npm install #{resource[:name]}"`
    self.fail "Could not install: #{resource[:name]}" if output.include?("npm not ok")
  end

  def uninstall
    output = `sudo -u node -b sh -c "export PATH=/home/node/opt/bin:${PATH}; cd /home/node; npm uninstall #{resource[:name]}"`
    self.fail "Could not uninstall: #{resource[:name]}" if output.include?("npm not ok")
  end

  def query
    version = nil
    self.class.npm_list(:justme => resource[:name])
  end
    
end

