class nodejs::npm($user) {

  $npm_path = "/opt/node/lib/npm"

  package { "git":
    ensure => "installed"
  }

  file { "/opt/node/lib":
    ensure => "directory",
    owner => "$user",
    group => "$user",
  }

  vcsrepo { $npm_path:
    ensure	=> present,
    provider => git,
    source => "http://github.com/isaacs/npm.git",
    require => [Exec["install_node"], Package["git"], File["/opt/node/lib"]], 
    revision => "HEAD"
  }

  
  exec { "make_npm":
    cwd => "$npm_path",
    command => "make install",
    require => Vcsrepo[$npm_path],
    creates => "/opt/node/bin/npm",
    timeout => 0,
    path    => ["/usr/bin/","/bin/", "/opt/node/bin"],
  }
    
}
