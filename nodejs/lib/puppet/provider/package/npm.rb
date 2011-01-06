
Puppet::Type.type(:package).provide :npm, :parent => Puppet::Provider::Package do
  desc "node.js package management with npm"

  commands :npm_cmd => "/home/node/opt/bin/npm"
  raise Puppet::Error, "The npm provider can only be used as root" if Process.euid != 0

  def self.npm_list
    
    begin
      s = `sudo -u node sh -c \"export PATH=/home/node/opt/bin; npm ls installed\"`
      list = s.split("\n").collect do |set|
        if npm_hash = npm_split(set)
          npm_hash[:provider] = :npm
          npm_hash
        else
          nil
        end
      end.compact
    rescue Puppet::ExecutionFailure => detail
      raise Puppet::Error, "Could not list npm packages: #{detail}"
    end
    
    return list.shift
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

  def install
    system("sudo -u node sh -c \"export PATH=/home/node/opt/bin; npm install #{@resource[:name]}\"")
  end

  def uninstall
    system("sudo -u node sh -c \"export PATH=/home/node/opt/bin; npm uninstall #{@resource[:name]}\"")
  end

  def query
    version = nil
    self.class.npm_list
  end
    
end

