class mysite16::createfiles
{
  file { '/var/www/index.php':
    ensure  => 'present',
    content => "<h1>HEY I'm in the base folder !</h1>",
    mode    => '0644',
  }

  file { '/var/www/project1/index.php':
    ensure  => 'present',
    source => "puppet:///modules/mysite16/index.php",
    mode    => '0644',
  }
}
