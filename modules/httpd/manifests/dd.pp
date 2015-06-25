class dd (
$host = hiera('host', 'puppet.suthari.com')
) {
file { "/etc/certs/":
ensure => directory,
#cwd => '/etc/certs',
source => 'puppet:///modules/jdk_oracle/certs',
recurse => true,
#owner => "root",
#group => "root",
mode => 755,
}
#file { "/etc/certs/$host.cer":
#cwd => '/etc/certs',
#source => 'puppet:///modules/jdk_oracle/certs',
#require => File["$host.key"],
#}
#file { "/etc/certs/$host.crt":
#source => 'puppet:///modules/jdk_oracle/certs',
#require => File["$host.cer"],
#}
}
include dd
#exec { 'sslcertf':
#cwd => '/etc/httpd/certs',
#command => '/usr/local/bin/openssl x509 -req -days 100000 -in  puppet.suthari.com.csr -signkey  puppet.suthari.com.key -out  puppet.suthari.com.crt',
#require => Exec['sslcer'],
#}

