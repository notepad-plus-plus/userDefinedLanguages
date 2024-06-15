#!/usr/local/bin/python3

import json
import os
import io
import sys

import requests
from hashlib import sha256
from jsonschema import Draft202012Validator, FormatChecker
from pathlib import Path, PurePath
import urllib

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
tmpl_tab_head = '''| Name | Author | Description |
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

def check_for_orphans(udlfile):

    from glob import glob

    # generate a map to determine which ids have ac, fl, and/or udls
    print("\nLook for UDLs, autoCompletions, and functionLists in %s" % udlfile["name"])
    id_map = {}
    for udl in udlfile["UDLs"]:
        id_str = udl["id-name"]
        # print("- %s" % id_str)
        if not id_str in id_map:
            id_map[id_str] = { 'autoCompletion': False, 'functionList': False, 'UDLs': True }

        if 'autoCompletion' in udl:
            id_map[id_str]['autoCompletion'] = udl['autoCompletion']
            tmp = udl['autoCompletion']
            #print("  - Adding %s['autoCompletion'] = %s " % (id_str, tmp))

            # need to handle when autoCompletion filename doesn't match id_name
            if tmp and str(tmp) != 'True':
                print("  - Also adding %s['autoCompletion'] = %s" % (tmp, tmp))
                if tmp != id_str:
                    if not tmp in id_map:
                        id_map[tmp] = { 'autoCompletion': False, 'functionList': False, 'UDLs': False }
                    id_map[tmp]['autoCompletion'] = tmp

        if 'functionList' in udl:
            id_map[id_str]['functionList'] = udl['functionList']
            tmp = udl['functionList']
            #print("  - Adding %s['functionList'] = %s " % (id_str, tmp))

            # need to handle when functionList filename doesn't match id_name
            if tmp and str(tmp) != 'True':
                print("  - Also adding %s['functionList'] = %s" % (tmp, tmp))
                if tmp != id_str:
                    if not tmp in id_map:
                        id_map[tmp] = { 'autoCompletion': False, 'functionList': False, 'UDLs': False }
                    id_map[tmp]['functionList'] = tmp

    print("\nCheck for files that are not listed in %s" % udlfile["name"])

    # now go through each directory, one XML at a time, and make sure that
    #   the file is referenced from at least one entry in the JSON
    for dir_name in ('UDLs', 'autoCompletion','functionList'):
        for file_found in Path(f'./{dir_name}').glob('*.xml'):
            id_str = PurePath(file_found).stem
            print("- checking known %s entries for id='%s'" % (dir_name, id_str))
            if not id_str in id_map:
                post_error("Checking for orphaned files in directory '%s/': id='%s' not in JSON" % (dir_name, id_str))
                #return     # chose not to return, so that it will show all errors for a new UDL/AC/FL in the same run
            elif not dir_name in id_map[id_str]:
                post_error("Checking for orphaned files in directory '%s/': %s[%s] not in JSON" % (dir_name, id_str, dir_name))
                #return     # chose not to return, so that it will show all errors for a new UDL/AC/FL in the same run
            elif not id_map[id_str][dir_name]:
                post_error("Checking for orphaned files in directory '%s/': %s didn't come with %s in JSON" % (dir_name, id_str, dir_name))
                #return     # chose not to return, so that it will show all errors for a new UDL/AC/FL in the same run

def gen_md_table(udlfile):
    print("\nGenerate Markdown Table from %s" % udlfile["name"])

    tab_text = "## UDL Definitions%s%s" % (tmpl_new_line, tmpl_new_line)
    # tab_text += "version %s%s" % (udlfile["version"], tmpl_new_line)
    tab_text += tmpl_tab_head

    ac_list = []
    fl_list = []

    # UDL Name = (ij.display-name)ij.id-name.xml or repolink
    # Author = ij.author
    # Description = " <details> <summary> " + first_two_lines(ij.description) + " </summary> " rest_of_text(ij.description) +"</details>"
    for udl in sorted(udlfile["UDLs"], key=lambda d: d['display-name'].casefold()):
        # link to either repo or local copy of XML
        udl_link = udl["repository"]
        if not udl_link:
            udl_link = "./UDLs/" + udl["id-name"] + ".xml"

        # make sure all URL are properly encoded for non-http(s) paths
        if not (len(udl_link)>4 and udl_link[0:4]=="http"):
            udl_link = urllib.parse.quote(udl_link)

        # author name (with optional link to homepage)
        mailto = ""
        if ' <mailto:' in udl["author"]:
            p = udl["author"].find(' <mailto:')
            m = p + 2
            e = udl["author"].find('>', p)
            mailto = udl["author"][m:e]
            author = udl["author"][:p]
        else:
            author = udl["author"]

        if 'homepage' in udl:
            author = "[%s](%s)" % (author, udl["homepage"])
        elif mailto:
            author = "[%s](%s)" % (author, mailto)

        # concat name and author
        tab_line = tmpl_tr_b + "[" + udl["display-name"] +"](" + udl_link + ")" + tmpl_td + author + tmpl_td

        # grab description, and summarize if it's long...
        descr = udl["description"]
        descr = descr.replace(c_line_feed, tmpl_br).replace(c_line_break, '').replace("|", tmpl_vert)
        summary = first_two_lines(descr)
        rest = rest_of_text(descr)

        # add description to the current table row
        if summary:
            tab_line += " <details> <summary> %s </summary> %s </details>" % (summary, rest)
        else:
            tab_line += rest
        tab_line += tmpl_tr_e + tmpl_new_line
        tab_text += tab_line

        # if this entry has autoCompletion defined, add it to the list of autoCompletion
        if "autoCompletion" in udl:
            if udl["autoCompletion"]:
                if str(udl["autoCompletion"]) == "True":
                    ac_link = udl["id-name"] + ".xml"
                elif udl["autoCompletion"][0:4] == "http":
                    ac_link = udl["autoCompletion"]
                else:
                    ac_link = str(udl["autoCompletion"]) + ".xml"

                # print(f'autoCompletion: {udl["autoCompletion"]} => {ac_link}')

                # absolute path for existence testing
                ac_link_abs  = Path(os.path.join(os.getcwd(),"autoCompletion", ac_link))

                # relative path for correct linking of non-http(s) links
                if not (len(ac_link)>4 and ac_link[0:4]=="http"):
                    ac_link = "./autoCompletion/%s" % (urllib.parse.quote(ac_link))

                # use autoCompletionAuthor field if the autoCompletion has a different author than the UDL (like for RenderMan)
                if "autoCompletionAuthor" in udl:
                    if udl["autoCompletionAuthor"]:
                        author = udl["autoCompletionAuthor"]
                        mailto = ""
                        if ' <mailto:' in udl["autoCompletionAuthor"]:
                            p = udl["autoCompletionAuthor"].find(' <mailto:')
                            m = p + 2
                            e = udl["autoCompletionAuthor"].find('>', p)
                            mailto = udl["autoCompletionAuthor"][m:e]
                            author = udl["autoCompletionAuthor"][:p]

                # append to list if it exists, otherwise give error
                if not ("http:" in ac_link or "https:" in ac_link) and not ac_link_abs.exists():
                    print(f'ac_link = {ac_link}')
                    post_error(f'{udl["display-name"]}: autoCompletion file missing from repo: JSON id-name expects it at filename="{ac_link}"')
                else:
                    ac_list.append(tmpl_tr_b + "[" + udl["display-name"] +"](" + ac_link + ")" + tmpl_td + author + tmpl_td + udl["description"] + tmpl_tr_e)


        # if this entry has functionList defined, add it to the list of functionLists
        if "functionList" in udl:
            if udl["functionList"]:
                if str(udl["functionList"]) == "True":
                    fl_link = udl["id-name"] + ".xml"
                elif udl["functionList"][0:4] == "http":
                    fl_link = udl["functionList"]
                else:
                    fl_link = str(udl["functionList"]) + ".xml"

                # print(f'functionList: {udl["functionList"]} => {fl_link}')

                # absolute path for existence testing
                fl_link_abs  = Path(os.path.join(os.getcwd(),"functionList", fl_link))

                # relative path for correct linking of non-http(s) links
                if not (len(fl_link)>4 and fl_link[0:4]=="http"):
                    fl_link = "./functionList/%s" % (urllib.parse.quote(fl_link))

                # use functionListAuthor field if the functionList has a different author than the UDL (like for RenderMan)
                if "functionListAuthor" in udl:
                    if udl["functionListAuthor"]:
                        author = udl["functionListAuthor"]
                        mailto = ""
                        if ' <mailto:' in udl["functionListAuthor"]:
                            p = udl["functionListAuthor"].find(' <mailto:')
                            m = p + 2
                            e = udl["functionListAuthor"].find('>', p)
                            mailto = udl["functionListAuthor"][m:e]
                            author = udl["functionListAuthor"][:p]

                # append to list if it exists, otherwise give error
                if not ("http:" in fl_link or "https:" in fl_link) and not fl_link_abs.exists():
                    print(f'fl_link = {fl_link}')
                    post_error(f'{udl["display-name"]}: functionList file missing from repo: JSON id-name expects it at filename="{fl_link}"')
                else:
                    fl_list.append(tmpl_tr_b + "[" + udl["display-name"] +"](" + fl_link + ")" + tmpl_td + author + tmpl_td + udl["description"] + tmpl_tr_e)

    print(f'- Number of UDLs: {len(udlfile["UDLs"])}')

    # add the Auto-Completion Definitions in a separate table at the end
    tab_text += tmpl_new_line
    tab_text += "## Auto-Completion Definitions%s%s" % (tmpl_new_line, tmpl_new_line)
    tab_text += tmpl_tab_head
    tab_text += tmpl_new_line.join(ac_list)
    print(f'- Number of AutoCompletions referenced: {len(ac_list)}')

    # add the FunctionList Definitions in a separate table at the end
    tab_text += tmpl_new_line
    tab_text += tmpl_new_line
    tab_text += "## FunctionList Definitions%s%s" % (tmpl_new_line, tmpl_new_line)
    tab_text += tmpl_tab_head
    tab_text += tmpl_new_line.join(fl_list)
    print(f'- Number of FunctionLists referenced: {len(fl_list)}')

    # always end the file with a newline
    tab_text += tmpl_new_line

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

    print("\nValidating %s" % filename)

    for error in schema.iter_errors(udlfile):
        post_error(error.message)

    idnames = []
    displaynames = []
    repositories = []
    response = []

    print("\nParsing %s" % filename)

    for udl in udlfile["UDLs"]:
        print("- " + udl["display-name"])

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

        # look at optional autoCompletion
        if "autoCompletion" in udl:
            # print(f'\tautoCompletion: {udl["autoCompletion"]}')
            if udl["autoCompletion"]:
                if str(udl["autoCompletion"]) == "True":
                    ac_link = udl["id-name"] + ".xml"
                elif udl["autoCompletion"][0:4] == "http":
                    ac_link = udl["autoCompletion"]
                else:
                    ac_link = str(udl["autoCompletion"]) + ".xml"
                ac_link_abs  = Path(os.path.join(os.getcwd(),"autoCompletion", ac_link))

                if ac_link[0:4] == "http":
                    try:
                        response = requests.get(ac_link)
                        print(f'  + also confirmed autoCompletion URL: {ac_link}')
                    except requests.exceptions.RequestException as e:
                        post_error(str(e))
                        continue
                elif not ac_link_abs.exists():
                    post_error(f'{udl["display-name"]}: autoCompletion file missing from repo: JSON id-name expects it at filename="autoCompletion/{ac_link}"')
                else:
                    print(f'  + also confirmed "autoCompletion/{ac_link}"')


        # look at optional functionList
        if "functionList" in udl:
            # print(f'\tfunctionList: {udl["functionList"]}')
            if udl["functionList"]:
                if str(udl["functionList"]) == "True":
                    fl_link = udl["id-name"] + ".xml"
                elif udl["functionList"][0:4] == "http":
                    fl_link = udl["functionList"]
                else:
                    fl_link = str(udl["functionList"]) + ".xml"
                fl_link_abs  = Path(os.path.join(os.getcwd(),"functionList", fl_link))

                if fl_link[0:4] == "http":
                    try:
                        response = requests.get(fl_link)
                        print(f'  + also confirmed functionList URL: {fl_link}')
                    except requests.exceptions.RequestException as e:
                        post_error(str(e))
                        continue
                elif not fl_link_abs.exists():
                    post_error(f'{udl["display-name"]}: functionList file missing from repo: JSON id-name expects it at filename="functionList/{fl_link}"')
                else:
                    print(f'  + also confirmed "functionList/{fl_link}"')

    return udlfile


# initial reading and parsing
udl_file_structure = parse("udl-list.json")

# check for orphans: files in the directory that aren't listed in JSON
# udl_file_structure = json.loads(open("udl-list.json", encoding="utf8").read())
check_for_orphans(udl_file_structure)

# update markdown file
with open("udl-list.md", "w", encoding="utf8") as md_file:
    md_file.write(gen_md_table(udl_file_structure))

if has_error:
    sys.exit(-2)
else:
    sys.exit()
