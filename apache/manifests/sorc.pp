class httpd::sorc(
  $version        = hiera('apache::version',        'default' ),
  $version_u      = hiera('apache::version_update', 'default' ),
  $version_b      = hiera('apache::version_build',  'default' ),
  $install_dir    = hiera('apache::install_dir',    '/opt' ),
  $use_cache      = hiera('apache::use_cache',      true ),
  $cache_source   = 'puppet:///modules/httpd/',
  $listenport     = hiera('listenport', '80' ),
  $proxyport      = hiera('proxyport', '8080' ),
  $ipadr   = hiera('ipaddrs',  '10.5.2.120' ),
  $proxy_on       = hiera('proxy-', false),
  $ssl_on         = hiera('ssl-', true),
  $sslport        = hiera('sslport', '443'),
  $sslproxyport   = hiera('sslproxyport', '8443'),
 ) {
  if $ensure == 'installed' {
    # Set default exec path for this module
    Exec { path  => ['/usr/bin', '/usr/sbin', '/bin', '/bin/bash', '/bin/sh' ] }
    }
 $apcheURL = "apache.tar.gz"
  $apachehome = "${install_dir}/apache"
  $pcrehome = "$apachehome/pcre-8.34"
  $httpdhome = "$apachehome/httpd-2.2.15"
  $installtpcre = "configure --prefix=$apachehome/pcre && make && make install"
  $installapache = "configure --prefix=$apachehome/httpd --with-included-apr --with-included-apr-utl --with-included-pcre --enable-ssl --enable-so && make && make install"

if ( $use_cache ){
 # file { '${install_dir}':
 #     ensure => present,
 #     mode    => '0755',
 #     }

    file { "${install_dir}/${apacheURL}":
       source  => "${cache_source}${apacheURL}",
#       require => File['${install_dir}']
      } 
#      exec { 'get_apache_installer':
#        cwd     => $install_dir,
#        creates => "${install_dir}/apache_from_cache",
#        command => 'touch apache_from_cache',
#      }

#      file { "${install_dir}":
#      ensure => present,
#       mode    => '0755',
#      	} 
 exec { 'extract_apache':
 cwd     => "${install_dir}/",
 command => "/bin/tar zxf ${apacheURL}",
 creates => $apachehome,
 require => File["${install_dir}/${apacheURL}"] #Exec['get_apache_installer'],
 }
# exec { 'installpcre':
# cwd     => "$pcrehome",
# command => "${pcrehome}/${installtpcre}",
# require => Exec['extract_apache'],
# }
 exec { 'make_apache':
 cwd     => "$httpdhome",
 command => "${httpdhome}/${installapache}",
 before => File["$apachehome/httpd/conf/httpd.conf"],
 }
 file { "$apachehome/httpd/conf/httpd.conf":
 ensure => present,
 mode => '755',
 content => template("/etc/puppet/modules/httpd/templates/httpd.conf.erb"),
 require => Exec['make_apache'],
 }
  if ($proxy_on) {
      file { "$apachehome/httpd/conf/extra/proxy-html.conf":
      ensure => present,
      mode => '755',
      content => template("/etc/puppet/modules/httpd/templates/proxy.conf.erb"),
      # soruce  => "puppet://templates/proxy.conf.erb",
      require => File["$apachehome/httpd/conf/httpd.conf"],
      }
 }
  if ($ssl_on) {
        file { "$apachehome/httpd/conf/extra/html-ssl.conf":
      ensure => present,
      mode => '755',
      content => template("/etc/puppet/modules/httpd/templates/ssl.conf.erb"),
      require => File["$apachehome/httpd/conf/httpd.conf"],
      }
 }
 exec { 'start_apache':
 cwd  => "$apachehome/httpd/bin",
 command => "$apachehome/httpd/bin/apachectl -k start",
 require => Exec['make_apache'],
 }
 }
 }
include httpd::sorc
