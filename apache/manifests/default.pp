class apache(
  $version        = hiera('apache::version',        '3' ),
  $version_u      = hiera('apache::version_update', '1' ),
  $version_b      = hiera('apache::version_build',  '1' ),
  $install_dir    = hiera('apache::install_dir',    '/opt' ),
  $use_cache      = hiera('apache::use_cache',      true ),
  $cache_source   = 'puppet:///modules/httpd',
  $ensure         = 'installed'
  ) {
  if $ensure == 'installed' {
    # Set default exec path for this module
    Exec { path  => ['/usr/bin', '/usr/sbin', '/bin', '/bin/bash', '/bin/sh' ] }
    }
 $tcsURL = "apache.tar.gz"
  $apachehome = "${install_dir}/apache"
  $pcrehome = "$apachehome/pcre-8.34"
  $httpdhome = "$apachehome/httpd-2.4.12"
  $installtpcre = "configure --prefix=$apachehome/pcre && make && make install"
  $installapache = "configure --prefix=$apachehome/httpd --with-included-apr --with-included-apr-utl --with-pcre=$apachehome/pcre/bin/pcre-config && make && make install"

if ( $use_cache ){
    file { "${install_dir}/${tcsURL}":
        source  => "${cache_source}${tcsURL}",
        require => File[$install_dir]
      } ->
      exec { 'get_tc_installer':
        cwd     => $install_dir,
        creates => "${install_dir}/tc_from_cache",
        command => 'touch tc_from_cache',
      }

       file { "${install_dir}/":
        ensure => directory,
        mode    => '0755',
	} 
 exec { 'extract_tc':
 cwd     => "${install_dir}/",
 command => "/bin/tar xf ${tcsURL}",
 creates => $apachehome,
 require => Exec['get_tc_installer'],
 }
 exec { 'installpcre':
 cwd     => "$pcrehome",
 command => "${pcrehome}/${installtpcre}",
 require => Exec['extract_tc'],
 }
 exec { 'make_apache':
 cwd     => "$httpdhome",
 command => "${httpdhome}/${installapache}",
 require => Exec['installpcre'],
 }
 file { "$apachehome/httpd/conf/httpd.conf":
 ensure => present,
 mode => '755',
 content => template("/etc/puppet/modules/httpd/templates/httpd.conf.erb"),
 require => Exec['make_apache'],
 }
 file { "$apachehome/httpd/conf/extra/proxy-html.conf":
 ensure => present,
 mode => '755',
 content => template("/etc/puppet/modules/httpd/templates/proxy.conf.erb"),
 require => File["$apachehome/httpd/conf/httpd.conf"],
 }
 exec { 'start_apache':
 cwd  => "$apachehome/httpd/bin",
 command => "$apachehome/httpd/bin/apachectl -k start",
 require => Exec['make_apache'],
 }
 }
 }
include apache
