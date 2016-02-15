# -*- coding: utf-8 -*-

import socket
import re

def to_con_addr(ip,sid):
    return re.sub(r"([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9])",r"\1.{0}.\3.\4".format(sid),ip)

class FilterModule(object):
    """ utility filters for operating on hashes """

    def filters(self):
        return {
            'A': socket.gethostbyname,
            'to_con_addr': to_con_addr 
        }
