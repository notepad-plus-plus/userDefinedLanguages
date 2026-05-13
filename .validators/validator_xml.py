#!/usr/local/bin/python3

import os
import io
import sys
import re

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


def parse_xml_file(filename_xml, filename_xsd = None, doCheckEncoding = False):

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

    # issue#392: require prolog set the encoding
    if doCheckEncoding:
        #encoding = doc.docinfo.encoding
        encoding = get_prolog_encoding(filename_xml)
        if encoding is None or encoding.upper() != "UTF-8":
            post_error(f'{filename_xml}: XML prolog encoding is "{encoding}"; must be "UTF-8"')
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
            parse_xml_file(os.path.join("UDLs", file), '.validators/userDefineLangs.xsd', True)

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

def get_prolog_encoding(filename: str) -> str | None:
    """
    Analyzes the raw XML prolog to check for an explicit encoding attribute.

    Returns:
        None (type)  - If there is absolutely no xml prolog found.
        None (type)  - If a prolog exists, but the encoding attribute is missing.
        "" (str)     - If the encoding attribute is explicitly empty (encoding="").
        str          - The literal value of the encoding attribute if specified.
    """
    # Look only at the first 2048 bytes; XML declarations must start at byte 0
    with open(filename, 'rb') as f:
        chunk = f.read(2048)

    # Check if the file starts with the XML declaration opener
    # Account for standard UTF-8/ASCII or common byte-order marks (BOM)
    if b'<?xml' not in chunk:
        return None

    # Extract the full prolog string up to its closing tag
    try:
        prolog_bytes = chunk.split(b'?>')[0] + b'?>'
        prolog_str = prolog_bytes.decode('utf-8', errors='ignore')
    except Exception:
        return None

    # Strict regex check for the declaration block
    if not re.match(r'^\s*<\?xml\s', prolog_str):
        return None

    # Search for the encoding attribute and capture its quote-bounded contents
    match = re.search(r'\bencoding\s*=\s*(["\'])(.*?)\1', prolog_str)

    if match:
        return match.group(2)  # Returns actual value, or "" if empty

    return None  # Prolog exists, but encoding attribute does not

parse_xml_files_from_udls_dir()
parse_xml_files_from_autoCompletion_dir()
parse_xml_files_from_functionList_dir()

if has_error:
    sys.exit(-2)
else:
    sys.exit()
