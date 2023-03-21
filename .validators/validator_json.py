#!/usr/local/bin/python3

import json
import os
import io
import sys

import requests
from hashlib import sha256
from jsonschema import Draft202012Validator, FormatChecker
from pathlib import Path

api_url = os.environ.get('APPVEYOR_API_URL')
has_error = False

# constants for creation of UDL list overview
c_line_break = '\x0d'
c_line_feed = '\x0a'
c_space = ' '
c_sum_len = 100
tmpl_vert = '&vert;'
tmpl_br = '<br>'
tmpl_new_line = '\n'
tmpl_tr_b = '| '
tmpl_td   = ' | '
tmpl_tr_e = ' |'
tmpl_tab_head = '''|Name | Author | Description |
|-----|--------|-------------|
'''

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

def first_two_lines(description):
    if len(description) <= c_sum_len:
        return ""
    i = description.rfind(tmpl_br,0,c_sum_len)
    if i != -1:
        return description[:i]
    i = description.rfind(c_space,0,c_sum_len)
    if i != -1:
        return description[:i]
    return description[:c_sum_len]

def rest_of_text(description):
    return description[len(first_two_lines(description)):]

def gen_pl_table(filename):
    udlfile = json.loads(open(filename, encoding="utf8").read())
    tab_text = "## UDL list%s" % (tmpl_new_line)
    tab_text += "version %s%s" % (udlfile["version"], tmpl_new_line)
    tab_text += tmpl_tab_head

    # UDL Name = (ij.display-name)ij.id-name.xml or repolink
    # Author = ij.author
    # Description = " <details> <summary> " + first_two_lines(ij.description) + " </summary> " rest_of_text(ij.description) +"</details>"
    for udl in udlfile["UDLs"]:
        udl_link = udl["repository"]
        if not udl_link:
            udl_link = "./UDLs/" + udl["id-name"] + ".xml"
        tab_line = tmpl_tr_b + "[" + udl["display-name"] +"](" + udl_link + ")" + tmpl_td + udl["author"] + tmpl_td
        descr = udl["description"]
        descr = descr.replace(c_line_feed, tmpl_br).replace(c_line_break, '').replace("|", tmpl_vert)
        summary = first_two_lines(descr)
        rest = rest_of_text(descr)
        if summary:
            tab_line += " <details> <summary> %s </summary> %s </details>" % (summary, rest)
        else:
            tab_line += rest
        tab_line += tmpl_tr_e + tmpl_new_line
        tab_text += tab_line
    return tab_text

def parse(filename):
    try:
        schema = json.loads(open(".validators/udl.schema").read())
        schema = Draft202012Validator(schema, format_checker=FormatChecker())
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

        if udl["repository"] != "" and response.status_code != 200:
            post_error(f'{udl["display-name"]}: failed to download udl from repository="{udl["repository"]}". Returned code {response.status_code}')
            continue

        # check if file exists in this repo if no external link is available
        if not udl["repository"]:
            udl_link = udl["id-name"] + ".xml"
            udl_link_abs  = Path(os.path.join(os.getcwd(),"UDLs", udl_link))
            if not udl_link_abs.exists():
                post_error(f'{udl["display-name"]}: udl file missing from repo: JSON id-name expects it at filename="{udl_link}"')

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
with open("udl-list.md", "w", encoding="utf8") as md_file:
    md_file.write(gen_pl_table("udl-list.json"))

if has_error:
    sys.exit(-2)
else:
    sys.exit()
