# This code fragment downloads tomcat 8.0 then starts the service
#
class { 'tomcat': }
include java

tomcat::instance { 'test':
    source_url => 'http://ftp.wayne.edu/apache/tomcat/tomcat-7/v7.0.62/bin/apache-tomcat-7.0.62.zip'
}
tomcat::service { 'default':
catalina_base => '/opt/apache-tomcat/apache-tomcat-7.0.62',
}
file { '/opt/apache-tomcat/apache-tomcat-7.0.62/bin/catalina.sh':
  mode   => '7777',
  }

