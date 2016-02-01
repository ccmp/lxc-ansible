#!/usr/bin/env python
import os
import sys
import json 

class SampleInventory(object):

    def __init__(self):
        self.inventory = {}

        self.inventory=self.sample_inventory()
        print json.dumps(self.inventory)

    def sample_inventory(self):
        return {
            'service2-lvs1': {
                'hosts': ['lvs01']
            },
            'service2-lvs2': {
                'hosts': ['lvs02']
            },
            'service2-web1': {
                'hosts': ['web01']
            },
            'service2-web2': {
                'hosts': ['web02']
            }
        }
 

SampleInventory()
