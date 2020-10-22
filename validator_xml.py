#!/usr/local/bin/python3

import os
import io
import sys

import requests
from hashlib import sha256
from lxml import etree

api_url = os.environ.get('APPVEYOR_API_URL')
has_error = False


def post_error(message):
    global has_error

    has_error = True

    message = {
        "message": message,
        "category": "error",
        "details": ""
    }

    if api_url:
        requests.post(api_url + "api/build/messages", json=message)
    else:
        from pprint import pprint
        pprint(message)


def parse_xml_file(filename_xml):

    # open and read schema file
    #with open(filename_xsd, 'r') as schema_file:
        #schema_to_check = schema_file.read()

    # open and read xml file
    with open(filename_xml, 'r', encoding="utf-8") as xml_file:
        xml_to_check = xml_file.read()

    # parse xml
    try:
        doc = etree.parse(io.StringIO(xml_to_check))
        #print(f'{filename_xml} XML well formed, syntax ok.')

    # check for file IO error
    except IOError:
        #print('Invalid File')
        post_error(f'{filename_xml}: IOError Invalid File')


    # check for XML syntax errors
    except etree.XMLSyntaxError as err:
        #print('XML Syntax Error, see error_syntax.log')
        post_error(f'{filename_xml}: {str(err.error_log)}: XMLSyntaxError Invalid File')

    except:
        #print('Unknown error.')
        post_error(f'{filename_xml}: Unknown error. Maybe check that no xml version is in the first line.')

def parse_xml_files_from_udls_dir():

    for file in os.listdir("UDLs"):
        if file.endswith(".xml"):
            #print(os.path.join("UDLs", file))
            parse_xml_file(os.path.join("UDLs", file))

def parse_xml_files_from_autoCompletions_dir():

    for file in os.listdir("autoCompletions"):
        if file.endswith(".xml"):
            #print(os.path.join("autoCompletions", file))
            parse_xml_file(os.path.join("autoCompletions", file))

parse_xml_files_from_udls_dir()
parse_xml_files_from_autoCompletions_dir()

if has_error:
    sys.exit(-2)
else:
    sys.exit()
