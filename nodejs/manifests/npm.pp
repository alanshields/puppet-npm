
class nodejs::npm {

  include nodejs

  exec { "clone_npm":
    cwd => "/tmp",
    command => "/usr/bin/git clone http://github.com/isaacs/npm.git",
    creates => "/tmp/npm",
    require => Exec["install_node"],
    user => "node"
  }
  
  exec { "make_npm":
    cwd => "/tmp/npm",
    command => "/home/node/opt/bin/node cli.js install npm",
    require => Exec["clone_npm"],
    creates => "/home/node/opt/bin/npm",
    user => "node",
    timeout => "-1"
  }

  file { "/home/node/opt/bin/npm":
    owner => "node",
    group => "node",
    recurse => true,
    require => Exec["make_npm"]
  }
    
}
