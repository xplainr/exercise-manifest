
## site.pp ##

# Define filebucket 'main':
filebucket { 'main':
  server => 'learn.localdomain',
  path   => false,
}

# Make filebucket 'main' the default backup location for all File resources:
File { backup => 'main' }

# DEFAULT NODE
node default {

}

#Begin Resource Definitions

#Nginx Setup Class
class { 'nginx::setup':
  ensure  => 'present',
  enable  => 'true',
  service => 'running',
  version => 'installed',
#  before  => File['/etc/nginx/conf.d/exercise.conf', '/var/www/nginx-default/index.html'],
} ->

#Page Local Git Repo Creation and Clone
  vcsrepo { '/tmp/page_repo':
    ensure   => latest,
    provider => git,
    #before   => File['/var/www/nginx-default/index.html'],
    source   => 'https://github.com/xplainr/exercise-webpage.git',
    revision => 'master',
} ->

#Nginx Conf Local Git Repo Creation and Clone
  vcsrepo { '/tmp/conf_repo/':
    ensure   => latest,
    provider => git,
    #before   => File['/etc/nginx/conf.d/exercise.conf'],
    source   => 'https://github.com/xplainr/exercise-conf.git',
    revision => 'master',
} ->

#Puppet 2.7 does not seem to handle full-path ensure statements, so it has been split.
#Ensure www Destination Directory Exists
file {'/var/www':
ensure => directory,
} ->

#This is the second half of ensure statement.
#Ensure index.html Destination Directory Exists
file {'/var/www/nginx-default/':
ensure => directory,
} ->

#Page Resource
file {'/var/www/nginx-default/index.html':
  ensure   => present,
  source   => ["/tmp/page_repo/index.html"],
} ->

#Nginx Conf Resource
file {'/etc/nginx/conf.d/exercise.conf':
  ensure   => present,
  source   => ["/tmp/conf_repo/exercise.conf"],
}
