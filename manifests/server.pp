# Copyright 2017 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: vernemq::server
#

class vernemq::server (
  $cluster_cookie,
  $infra_service_password,
  $websocket_port = 80,
  $websocket_tls_port = 443,
  $infra_service_username = 'infra',
  $enable_tls = false,
  $ca_file = undef,
  $cert_file = undef,
  $key_file = undef,
  $master_node = undef,
) {
  file {'/etc/vernemq/.vmq.passwd.unhashed':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('vernemq/vmq.passwd.erb'),
    require => Package['vernemq'],
  }
  # NOTE(mtreinish): keep 2 copies to avoid running a rehash on every puppet
  # update
  file {'/etc/vernemq/vmq.passwd':
    ensure  => present,
    source  => '/etc/vernemq/.vmq.passwd.unhashed',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => File['/etc/vernemq/.vmq.passwd.unhashed'],
  }

  exec {'hash_password':
    command     => 'vmq-passwd -U /etc/vernemq/vmq.passwd',
    path        => ['/usr/bin', '/usr/sbin', '/bin/', '/sbin',],
    environment => 'HOME=/root',
    subscribe   => File['/etc/vernemq/vmq.passwd'],
    refreshonly => true,
  }

  if $master_node != undef {
    exec {'join_cluster':
      command     => "vmq-admin cluster join discovery-node VerneMQ@${master_node}",
      path        => ['/usr/bin', '/usr/sbin', '/bin', '/sbin',],
      require     => Service['vernemq'],
      environment => 'HOME=/root',
    }
  }

  if $ca_file != undef {
    file { '/etc/vernemq/cacert.pem':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $ca_file,
      require => Package['vernemq'],
      before  => File['/etc/vernemq/vernemq.conf'],
    }
  }

  if $cert_file != undef {
    file { '/etc/vernemq/cert.pem':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $cert_file,
      require => Package['vernemq'],
      before  => File['/etc/vernemq/vernemq.conf'],
    }
  }

  if $key_file != undef {
    file { '/etc/vernemq/key.pem':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $key_file,
      require => Package['vernemq'],
      before  => File['/etc/vernemq/vernemq.conf'],
    }
  }

  file {'/etc/vernemq/vmq.acl':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => true,
    content => template('vernemq/vmq.acl.erb'),
  }

  file {'/etc/vernemq/vernemq.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('vernemq/vernemq.conf.erb'),
    require => File['/etc/vernemq/vmq.acl'],
  }

  service { 'vernemq':
    ensure     => running,
    hasrestart => true,
    subscribe  => [
      File['/etc/vernemq/vmq.passwd'],
      Exec['hash_password'],
      File['/etc/vernemq/vernemq.conf'],
    ],
  }

}
