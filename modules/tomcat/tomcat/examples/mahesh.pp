# This code fragment downloads tomcat 8.0 then starts the service
#
class { 'tomcat': }
include java
tomcat::instance { 'test': 
    source_url => 'http://ftp.wayne.edu/apache/tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62.zip',
    notify => Exec['change']
}
exec{ "change":
command => '/bin/chmod +x /opt/apache-tomcat/apache-tomcat-7.0.62/bin/catalina.sh',
        path => "/bin",
}
exec { 'run_my_script':
     command => '/etc/profile.d/java.sh',
     refreshonly => true,
  }
tomcat::service { 'default':
java_home => '/opt/jdk1.8.0_45',
catalina_base => '/opt/apache-tomcat/apache-tomcat-7.0.62',
}
