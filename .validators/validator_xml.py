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


def parse_xml_file(filename_xml, filename_xsd = None):

    print(filename_xml)

    # parse xml
    try:
        doc = etree.parse(filename_xml)
        #print(f'{filename_xml} XML well formed, syntax ok.')

    # check for file IO error
    except IOError:
        #print('Invalid File')
        post_error(f'{filename_xml}: IOError Invalid File')
        return


    # check for XML syntax errors
    except etree.XMLSyntaxError as err:
        #print('XML Syntax Error, see error_syntax.log')
        post_error(f'{filename_xml}: {str(err.error_log)}: XMLSyntaxError Invalid File')
        return

    except:
        #print('Unknown error.')
        post_error(f'{filename_xml}: Unknown error. Maybe check that no xml version is in the first line.')
        return

    # open and read schema file
    # https://lxml.de/validation.html#xmlschema
    if filename_xsd is not None:
        try:
            xmlschema_doc = etree.parse(filename_xsd)
            #print(f'{filename_xml} | {filename_xsd} XML well formed, syntax ok.')

        # error reading XSD
        except IOError:
            post_error(f'{filename_xml} | {filename_xsd}: IOError Invalid File')
            return

        # error parsing XSD
        except etree.XMLSyntaxError as err:
            post_error(f'{filename_xml} | {filename_xsd}: {str(err.error_log)}: XMLSyntaxError Invalid File')
            return

        # other error
        except Exception as err:
            post_error(f'{filename_xml} | {filename_xsd}: Unknown error {str(err.error_log)} reading Schema .xsd file.')
            return

        # Next, extract the schema object from the schema_doc
        try:
            xmlschema = etree.XMLSchema(xmlschema_doc)
            #print(f'{filename_xml} | {filename_xsd}: SCHEMA OBJECT OK')

        # error with Schema
        except etree.XMLSchemaError as err:
            post_error(f'{filename_xml} | {filename_xsd}: {str(err.error_log)}: XMLSchemaError')
            return

        # other error
        except Exception as err:
            post_error(f'{filename_xml} | {filename_xsd}: Unknown error {str(err.error_log)} obtaining schema object')
            return

        # finally, validate the XML against the schema
        if not xmlschema.validate(doc):
            post_error(f'{filename_xml} | {filename_xsd}: Validation error {str(xmlschema.error_log)}')
            return
        #else:
        #    print(f'{filename_xml} | {filename_xsd}: VALIDATION OK')

def parse_xml_files_from_udls_dir():

    for file in os.listdir("UDLs"):
        if file.endswith(".xml"):
            #print(os.path.join("UDLs", file))
            parse_xml_file(os.path.join("UDLs", file), '.validators/userDefineLangs.xsd')

def parse_xml_files_from_autoCompletion_dir():

    for file in os.listdir("autoCompletion"):
        if file.endswith(".xml"):
            #print(os.path.join("autoCompletion", file))
            parse_xml_file(os.path.join("autoCompletion", file), '.validators/autoCompletion.xsd')

def parse_xml_files_from_functionList_dir():

    for file in os.listdir("functionList"):
        if file.endswith(".xml"):
            #print(os.path.join("functionList", file))
            parse_xml_file(os.path.join("functionList", file), '.validators/functionList.xsd')

parse_xml_files_from_udls_dir()
parse_xml_files_from_autoCompletion_dir()
parse_xml_files_from_functionList_dir()

if has_error:
    sys.exit(-2)
else:
    sys.exit()
