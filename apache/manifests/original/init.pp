class apacheserver(
  $install_dir    = hiera('tcs::install_dir',    '/data' ),
  $use_cache      = hiera('tcs::use_cache',      true ),
  $cache_source   = 'puppet:///modules/sources/',
 #$cache_source   = 'puppet:///modules/httpd/',
  $listenport     = hiera('listenport', '80' ),
  $proxyport      = hiera('proxyport', '8080' ),
  $ipadr   = hiera('ipaddrs',  '10.5.2.120' ),
  $proxy_on       = hiera('proxy-', false),
  $ssl_on         = hiera('ssl-', true),
  $sslport        = hiera('sslport', '443'),
  $sslproxyport   = hiera('sslproxyport', '8443'),
  $version        = hiera('httpdversion', '2.2.15'),
  $ensure         = 'installed'
  ) {
  if $ensure == 'installed' {
    # Set default exec path for this module
    Exec { path  => ['/usr/bin', '/usr/sbin', '/bin', '/bin/bash', '/bin/sh' ] }
    }
 $httpdURL = "httpd-$version.tar"
  $httphome = "${install_dir}/httpd-$version"
  $installhttpd = "configure --prefix=${install_dir}/httpserver -with-included-apr --with-included-apr-utl --with-included-pcre --enable-ssl --enable-so && make && make install"
 $startp= "apachectl -k start"
  $apache_home = "${install_dir}/httpserver"
if ( $use_cache ){
      file { "${install_dir}/${httpdURL}":
        source  => "${cache_source}${httpdURL}",
        require => File[$install_dir]
      } ->
      exec { 'get_htp_installer':
        cwd     => $install_dir,
        creates => "${install_dir}/htp_from_cache",
        command => 'touch htp_from_cache',
      }

       file { "${install_dir}/":
        ensure => directory,
        mode    => '0755',
	} 
 exec { 'extract_htp':
 cwd     => "${install_dir}/",
 command => "tar xf ${httpdURL}",
 creates => $httpdhome,
 require => Exec['get_htp_installer'],
 }
 exec { 'install_httpd':
 cwd     => "$httphome",
 command => "${httphome}/${installhttpd}",
 require => Exec['extract_htp'],
 }
 file { "${apache_home}/conf/httpd.conf":
 ensure => file,
 mode => '644',
 content => template("/etc/puppet/modules/httpd/templates/httpd.conf.erb"),
 require => Exec['install_httpd'],
 }
 file { "${apache_home}/conf.d":
 ensure => directory,
 mode => '755',
 require => Exec['install_httpd'],
 }
  file { "${apache_home}/conf.d/ssl.conf":
 ensure => file,
 mode => '644',
 content => template("/etc/puppet/modules/httpd/templates/ssl.conf.erb"),
 require => File["$apache_home/conf.d"],
 }
exec { 'start_http':
cwd     => "$apache_home",
command => "${httpdhome}/${starthttp}",
require => File["${apache_home}/conf/httpd.conf"],
}
}
}
include apacheserver
