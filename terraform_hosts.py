#!/usr/bin/env python

# Terraform-Ansible dynamic inventory for IBM Cloud
# Copyright (c) 2020, IBM UK
# steve_strutt@uk.ibm.com
ti_version = '0.1'
#

#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Can be used alongside static inventory files in the same directory 
#
# This inventory script expects to find Terraform tags of the form 
# group: ans_group associated with each tf instance to define the 
# host group membership for Ansible. Multiple group tags are allowed per host
#   
# terraform_inv.ini file in the same directory as this script, points to the 
# location of the terraform.tfstate file to be inventoried
# [TFSTATE]
# TFSTATE_FILE = /usr/share/terraform/ibm/Demoapp2x/terraform.tfstate
# 
# Validate correct execution: 
#   With ini file './terraform.py'
# Successful execution returns groups with lists of hosts and _meta/hostvars with a detailed
# host listing.
# Validate successful operation with ansible:
#   With - 'ansible-inventory -i inventory --list'



import json
import configparser
import os
from os import getenv
from collections import defaultdict
from argparse import ArgumentParser


def parse_params():
    parser = ArgumentParser('IBM Cloud Terraform inventory')
    parser.add_argument('--list', action='store_true', default=True, help='List Terraform hosts')
    parser.add_argument('--tfstate', '-t', action='store', dest='tfstate', help='Terraform state file in current or specified directory (terraform.tfstate default)')
    parser.add_argument('--version', '-v', action='store_true', help='Show version')
    args = parser.parse_args()
    # read location of terrafrom state file from ini if it exists 
    if not args.tfstate:
        args.tfstate = "terraform.tfstate"
    return args


def get_tfstate(filename):
    return json.load(open(filename))

class TerraformInventory:
    def __init__(self):
        self.args = parse_params()
        if self.args.version:
            print(ti_version)
        elif self.args.list:
            print(self.list_all())

    def list_all(self):
        hosts_vars = {}
        attributes = {}
        groups = {}
        inv_output = {}
        group_hosts = defaultdict(list)
        hosts = self.get_tf_instances()
        if hosts is not None: 
            for host in hosts:
                hosts_vars[host[0]] = host[1]
                groups = host[2]
                if groups is not None: 
                    for group in groups:
                        group_hosts[group].append(host[0])

        for group in group_hosts:
            inv_output[group] = {'hosts': group_hosts[group]}
        inv_output["_meta"] = {'hostvars': hosts_vars} 
        return json.dumps(inv_output, indent=2)    
        #return json.dumps({'all': {'hosts': hosts}, '_meta': {'hostvars': hosts_vars}}, indent=2)

    def get_tf_instances(self):
        tfstate = get_tfstate(self.args.tfstate)
        for resource in tfstate['resources']:

            if (resource['type'] == 'ibm_is_instance') & (resource['mode'] == 'managed'):
                for instance in resource['instances']:
                    tf_attrib = instance['attributes']
                    name = tf_attrib['name']
                    group = []

                    attributes = {
                        'id': tf_attrib['id'],
                        'image': tf_attrib['image'],
                        #'metadata': tf_attrib['user_data'],
                        'region': tf_attrib['zone'],
                        'ram': tf_attrib['memory'],
                        'cpu': tf_attrib['vcpu'][0]['count'],
                        'ssh_keys': tf_attrib['keys'],
                        'private_ipv4': tf_attrib['primary_network_interface'][0]['primary_ipv4_address'],
                        'ansible_host': tf_attrib['primary_network_interface'][0]['primary_ipv4_address'],
                        'ansible_ssh_user': 'root',
                        'provider': 'provider.ibm',
                        'tags': tf_attrib['tags'],
                    }
                
  
                    #tag of form ans_group: xxxxxxx is used to define ansible host group
                    for value in list(attributes["tags"]):
                        try:
                            curprefix, rest = value.split(":", 1)
                        except ValueError:
                            continue
                        if curprefix != "ans_group" :
                            continue  
                        group.append(rest)

                    yield name, attributes, group

            else:    
                continue        


if __name__ == '__main__':
    TerraformInventory()
