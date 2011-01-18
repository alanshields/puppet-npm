
class nodejs::npm {

  include nodejs

  package { "git":
    ensure => "installed"
  }

  file { "/home/node/opt/lib":
    ensure => "directory",
    owner => "node",
    group => "node"
  }

  exec { "clone_npm":
    cwd => "/home/node/opt/lib",
    command => "/usr/bin/git clone http://github.com/isaacs/npm.git",
    creates => "/home/node/opt/lib/npm",
    require => [Exec["install_node"], Package["git"], File["/home/node/opt/lib"]]
  }

  file { "/home/node/opt/lib/npm":
    ensure => "directory",
    owner => "node",
    group => "node",
    require => Exec["clone_npm"]
  }
  
  exec { "make_npm":
    cwd => "/home/node/opt/lib/npm",
    command => "/home/node/opt/bin/node /home/node/opt/lib/npm/cli.js install npm",
    require => [Exec["clone_npm"], File["/home/node/opt/lib/npm"]],
    creates => "/home/node/opt/bin/npm",
    user => "node",
    timeout => 0
  }

  file { "/home/node/opt/bin/npm":
    owner => "node",
    group => "node",
    recurse => true,
    require => Exec["make_npm"]
  }
    
}
