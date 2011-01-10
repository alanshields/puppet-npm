
# no ssl
class nodejs {

  package { "openssl":
    ensure => "installed"
  }

  package { "openssl-devel":
    ensure => "installed"
  }

  file { "/home/node":
    ensure => "directory",
    owner => "node"
  }

  file { "/home/node/opt":
    ensure => "directory",
    require => File["/home/node"],
    owner => "node"
  }

  user { "node":
    ensure => "present",
    require => File["/home/node"]
  }

  file { "/home/node/.bashrc":
    ensure => "present",
    owner => "node",
    content => template('nodejs/node_bashrc.erb')
  }

  file { "/tmp/node-v0.3.3.tar.gz":
    source => "puppet:///modules/nodejs/node-v0.3.3.tar.gz",
    ensure => "present",
    owner => "node"
  }

  exec { "extract_node":
    command => "tar -xzf node-v0.3.3.tar.gz",
    cwd => "/tmp",
    creates => "/tmp/node-v0.3.3",
    require => [File["/tmp/node-v0.3.3.tar.gz"], User["node"]]
  }

  exec { "configure_node":
    command => "./configure --prefix=/home/node/opt",
    cwd => "/tmp/node-v0.3.3",
    require => [Exec["extract_node"], Package["openssl"], Package["openssl-devel"]],
    timeout => "-1"
  }

  exec { "make_node":
    command => "make",
    cwd => "/tmp/node-v0.3.3",
    require => Exec["configure_node"],
    timeout => "-1"
  }

  exec { "install_node":
    command => "make install",
    cwd => "/tmp/node-v0.3.3",
    require => Exec["make_node"],
    timeout => "-1",
    creates => "/home/node/opt/bin/node"
  }

  file { "/home/node/opt/bin/node":
    owner => "node",
    group => "node",
    require => Exec["install_node"],
    recurse => true
  }

  file { "/home/node/opt/bin/node-waf":
    owner => "node",
    group => "node",
    recurse => true,
    require => Exec["install_node"]
  }

}

