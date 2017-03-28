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
#
# == Class: vernemq
#
# Full description of class emqttd here.
#
# === Parameters
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#
class vernemq {
  archive { '/tmp/vernemq_1.0.0.1_amd64.deb':
    source        => 'https://bintray.com/artifact/download/erlio/vernemq/deb/xenial/vernemq_1.0.0-1_amd64.deb',
    extract       => false,
    checksum      => '2bad1f6d09aa12cd1c3747bac017d741bada221a',
    checksum_type => 'sha1',
  }

  package { 'vernemq':
    ensure   => latest,
    source   => '/tmp/vernemq_1.0.0.1_amd64.deb',
    provider => 'dpkg',
    require  => [
      Archive['/tmp/vernemq_1.0.0.1_amd64.deb'],
    ]
  }

}
