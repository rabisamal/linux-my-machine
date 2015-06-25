class httpd (
  $listenport        = hiera('listenport', '80' ),
  $proxyport      = hiera('proxyport', '8080' ),
  $ip      = hiera('ipaddrs',  '10.5.2.120' ),
  $host = hiera('host', 'puppet.suthari.com'),
  $install_dir    = hiera('apache::install_dir', '/opt'),
  $use_cache      = hiera('apache::use_cache', true),
  $cache_source   = 'puppet:///modules/jdk_oracle/',
  ) {
  package { 'httpd':
      ensure => present,
         }
       ->
file {'/etc/httpd/conf/httpd.conf':  #Path to file on the client we want puppet to administer
     ensure  => file,  #Ensure it is a file, 
     mode => 0644,    #Permissions for the file
     content => template("/etc/puppet/modules/httpd/templates/httpd.conf.erb"), #Path to our customised file on the puppet server
     }

file {'/etc/httpd/conf.d/proxy.conf':  #Path to file on the client we want puppet to administer
     ensure  => file,  #Ensure it is a file,
     mode => 0644,    #Permissions for the file
     content => template("/etc/puppet/modules/httpd/templates/proxy-html.conf.erb"),
     }
file { "/etc/httpd/certs/":
ensure => directory,
source => 'puppet:///modules/jdk_oracle/certs',
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

# exec { 'sslkey':
# cwd => '/etc/httpd/certs', 
# command => '/usr/local/bin/openssl genrsa -out puppet.suthari.com.key 1024',
# require => File['/etc/httpd/certs'],
# }
# exec { 'sslcer':
# cwd => '/etc/httpd/certs',
# command => '/usr/local/bin/openssl req -new -key puppet.suthari.com.key -out puppet.suthari.com.csr',
# require => Exec['sslkey'],
# }
#exec { 'sslcertf':
#cwd => '/etc/httpd/certs',
#command => '/usr/local/bin/openssl x509 -req -days 100000 -in  puppet.suthari.com.csr -signkey  puppet.suthari.com.key -out  puppet.suthari.com.crt',
#require => Exec['sslcer'],
#}
      service { 'httpd':
      ensure     => running,
      enable     => true,
      subscribe => File['/etc/httpd/conf.d/proxy.conf'],  # Restart service if any any change is made to httpd.conf
}
}
include httpd
