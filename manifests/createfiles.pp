class mysite16::createfiles
{
  file { '/var/www/index.php':
    ensure  => 'present',
    source  => "puppet:///modules/mysite16/index_base.php",
    mode    => '0644',
  }

  file { '/var/www/project1/index.php':
    ensure  => 'present',
    source => "puppet:///modules/mysite16/index.php",
    mode    => '0644',
  }
}
