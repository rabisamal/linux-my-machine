class httpd (
  $listenport        = hiera('listenport', '80' ),
  $proxyport      = hiera('proxyport', '8080' ),
  $ipadr   = hiera('ipaddrs',  '10.5.2.120' ),
  $host = hiera('host', 'puppet.suthari.com'),
  $install_dir    = hiera('apache::install_dir', '/opt'),
  $use_cache      = hiera('apache::use_cache', true),
  $proxy_on       = hiera('proxy-', true),
  $ssl_on         = hiera('ssl-', true),
  $sslport        = hiera('sslport', '443'),
  $sslproxyport   = hiera('sslproxyport', '8443'),
  $cache_source   = 'puppet:///modules/jdk_oracle/',
  ) {
case $::osfamily {
  RedHat, Linux : {
  package { 'httpd':
  ensure => present,
  }
 file { '/etc/httpd/conf.d':
 ensure => directory,
 mode  => '755',
 }
       ->
file {'/etc/httpd/conf/httpd.conf':  #Path to file on the client we want puppet to administer
     ensure  => file,  #Ensure it is a file, 
     mode => 0644,    #Permissions for the file
     content => template("/etc/puppet/modules/httpd/templates/httpd.conf.erb"), #Path to our customised file on the puppet server
     }
if ($proxy_on) {
file {'/etc/httpd/conf.d/proxy.conf':  #Path to file on the client we want puppet to administer
     ensure  => file,  #Ensure it is a file,
     mode => 0644,    #Permissions for the file
     content => template("/etc/puppet/modules/httpd/templates/proxy.conf.erb"),
      require => Package['httpd'],
     }
 }
if ($ssl_on) {
 file {'/etc/httpd/conf.d/ssl.conf':
 ensure  => file,
 mode => 0644,
 content => template("/etc/puppet/modules/httpd/templates/ssl.conf.erb"),
 require => Package['httpd'],
 }
file { "/etc/httpd/certs/":
ensure => directory,
source => 'puppet:///modules/sources/certs',
recurse => true,
mode => 755,
before => Package['openssl'],
}

 package { 'openssl':
 ensure => present,
 require => Package['httpd'],
}
 package { 'mod_ssl':
 ensure => present,
 require => Package['openssl'],
}
}
      service { 'httpd':
      ensure     => running,
      enable     => true,
      subscribe => File['/etc/httpd/conf/httpd.conf'],  # Restart service if any any change is made to httpd.conf
}
}
Debian : {
service { 'apache2':
      ensure     => running,
      enable     => true,
      subscribe => File['/etc/apache2/conf.d/proxy.conf'],  # Restart service if any any change is made to httpd.conf
}
}
}
}
include httpd
