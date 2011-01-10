
class nodejs::httpconsole {

  include nodejs
  include nodejs::npm

  package { "eyes":
    provider => "npm",
    ensure => "installed",
    require => Exec["make_npm"]
  }

  package { "http-console":
    provider => "npm",
    ensure => "installed",
    require => [Exec["make_npm"], Package["eyes"]]
  }
}
