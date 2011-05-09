
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

  vcsrepo { "/home/node/opt/lib/npm":
    ensure	=> present,
    provider => git,
    source => "http://github.com/isaacs/npm.git",
    require => [Exec["install_node"], Package["git"], File["/home/node/opt/lib"]], 
    revision => "HEAD"
  }

  file { "/home/node/opt/lib/npm":
    ensure => "directory",
    owner => "node",
    group => "node",
    require => Vcsrepo["/home/node/opt/lib/npm"],
    recurse => true,
  }
  
  exec { "make_npm":
    cwd => "/home/node/opt/lib/npm",
    command => "make install",
    require => [Vcsrepo["/home/node/opt/lib/npm"], File["/home/node/opt/lib/npm"]],
    creates => "/home/node/opt/bin/npm",
    user => "node",
    timeout => 0,
    path    => ["/usr/bin/","/bin/"],
  }

  file { "/home/node/opt/bin/npm":
    owner => "node",
    group => "node",
    recurse => true,
    require => Exec["make_npm"]
  }
    
}
