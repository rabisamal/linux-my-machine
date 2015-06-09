class java {
exec { 'java_tarball':
 cwd => '/opt/',
 command  => "/usr/bin/wget -q http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz?AuthParam=1433881222_4c0348a8d40e66c8d5d406c0d478fde3",
 path => '/usr/bin',
  }
exec { 'extract java tarball':
    cwd     => '/opt/',
    command => "tar -zxvf  /opt/jdk-8u45-linux-x64.tar.gz*",
    creates => '/opt/jdk1.8.0_45/bin',
    path => '/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin',
    require => Exec['java_tarball']
  }
file { '/etc/profile.d/java.sh':
 ensure => 'present',
 content => "export JAVA_HOME=/opt/jdk1.8.0_45/bin\nexport PATH=$PATH:/opt/jdk1.8.0_45/bin",
 }
exec { 'setting JAVA_HOME':
command => "/bin/bash -c 'source /etc/profile.d/java.sh'",
 }
}
include java
