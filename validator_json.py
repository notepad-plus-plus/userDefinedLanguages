#!/usr/local/bin/python3

import json
import os
import io
import sys

import requests
from hashlib import sha256
from jsonschema import Draft7Validator, FormatChecker

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

def parse(filename):
    try:
        schema = json.loads(open("udl.schema").read())
        schema = Draft7Validator(schema, format_checker=FormatChecker())
    except ValueError as e:
        post_error("udl.schema - " + str(e))
        return

    try:
        udlfile = json.loads(open(filename, encoding="utf8").read())
    except ValueError as e:
        post_error(filename + " - " + str(e))
        return

    for error in schema.iter_errors(udlfile):
        post_error(error.message)

    idnames = []
    displaynames = []
    repositories = []
    response = []

    for udl in udlfile["UDLs"]:
        print(udl["display-name"])

        try:
            if udl["repository"] != "" :
                response = requests.get(udl["repository"])
        except requests.exceptions.RequestException as e:
            post_error(str(e))
            continue

        if response.status_code != 200:
            post_error(f'{udl["display-name"]}: failed to download udl. Returned code {response.status_code}')
            continue

        # Hash it and make sure its what is expected
        #hash = sha256(response.content).hexdigest()
        #if udl["id"].lower() != hash.lower():
        #    post_error(f'{udl["display-name"]}: Invalid hash. Got {hash.lower()} but expected {udl["id"]}')
        #    continue

        #check uniqueness of json id-name, display-name and repository
        found = False
        for name in displaynames :
           if udl["display-name"] == name :
               post_error(f'{udl["display-name"]}: non unique display-name entry')
               found = True
        if found == False:
               displaynames.append(udl["display-name"])

        found = False
        for idname in idnames :
           if udl["id-name"] == idname :
               post_error(f'{udl["id-name"]}: non unique id-name entry')
               found = True
        if found == False:
           idnames.append(udl["id-name"])

        found = False
        for repo in repositories :
           if udl["repository"] != "" and udl["repository"] == repo :
                   post_error(f'{udl["repository"]}: non unique repository entry')
                   found = True
        if found == False:
           repositories.append(udl["repository"])


parse("udl-list.json")

if has_error:
    sys.exit(-2)
else:
    sys.exit()
