class mysite16
{
  # Edit local /etc/hosts files to resolve some hostnames used on your application.
  host { 'localhost':
    ensure       => 'present',
    target       => '/etc/hosts',
    ip           => '127.0.0.1',
    host_aliases => [
      'mysql1',
      'memcached1'
    ]
  }

  # Miscellaneous packages.
  $misc_packages = [
    'sendmail','vim-enhanced','telnet','zip','unzip','screen',
    'libssh2','libssh2-devel','gcc','gcc-c++','autoconf','automake','postgresql-libs'
  ]

  package { $misc_packages: ensure => latest }

  # PHP
  include ::yum::repo::remi
  package { 'libzip-last':
    require => Yumrepo['remi']
  }

  class{ '::yum::repo::remi_php56':
    require => Package['libzip-last']
  }

  class { 'php':
    version => 'latest',
    require => Yumrepo['remi-php56'],
  }

  php::module { [ 'devel', 'pear', 'xml', 'mbstring', 'pecl-memcache', 'soap' ]: }

  class{ 'apache': }

  apache::vhost { 'centos.dev':
    docroot       => '/var/www',
  }

  apache::vhost { 'project1.dev':
    docroot       => '/var/www/project1',
  }

  # MYSQL
  class { '::mysql::server':
    root_password    => 'vagrantpass',
  }

  mysql::db { 'mpwar_test':
    user     => 'mpwardb',
    password => 'mpwardb',
  }

  # Create files
  include mysite16::createfiles

  # Ensure Time Zone and Region.
  class { 'timezone':
    timezone => 'Europe/Madrid',
  }

  #NTP
  class { '::ntp':
    server => [ '1.es.pool.ntp.org', '2.europe.pool.ntp.org', '3.europe.pool.ntp.org' ],
  }

  # Ip Tables.
  if $operatingsystemrelease == '7.0.1406'
  {
    # firewalld - Centos 7
    firewalld_rich_rule { 'Accept HTTP':
      ensure  => present,
      zone    => 'public',
      service => 'http',
      action  => 'accept',
    }
  }
  else
  {
    package { 'iptables':
      ensure => present,
      before => File['/etc/sysconfig/iptables'],
    }
    file { '/etc/sysconfig/iptables':
      ensure  => file,
      owner   => "root",
      group   => "root",
      mode    => 600,
      replace => true,
      source  => "puppet:///modules/iptables/iptables.txt",
    }
    service { 'iptables':
      ensure     => running,
      enable     => true,
      subscribe  => File['/etc/sysconfig/iptables'],
    }
  }
}
