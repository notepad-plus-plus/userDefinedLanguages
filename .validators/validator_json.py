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
import time

from lxml import etree
from glob import glob


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
|------|--------|-------------|
'''
tmpl_fl_head = '''_If you download a functionList definition, remember to add the `<association>` row to your overrideMap.xml's `<associationMap>` section_

| Name | Author | Description | overrideMap `<association>` |
|------|--------|-------------|-----------------------------|
'''
tmpl_fl_pct = '`<association id="%s" userDefinedLangName="%s" />`'


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
        for file_found in Path(f'./{dir_name}').glob('*'):
            if PurePath(file_found).suffix != '.xml':
                post_error(f'Found non-XML file {file_found} when looking through {dir_name}')
                continue

            id_str = PurePath(file_found).stem
            if dir_name == 'autoCompletion':
                if id_str not in udlfile["id2ac"]:
                    post_error(f'Could not find id_str="{id_str}" in [id2ac] = {udlfile["id2ac"]}')
                    continue
                id_str = udlfile["id2ac"][id_str]

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
                udl_internal_name = udl["_autoCompletion_internal"]
                ac_link = udl["_ac_link"]
                ac_link_abs = udl["_ac_link_abs"]

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

                # generate the overrideMap <assocation> line
                fl_assoc = fl_link
                if fl_assoc[0:4] == "http":
                    pass    # TODO: need to strip all but name

                ov_map = tmpl_fl_pct % (fl_assoc, udl["display-name"])

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
                    fl_list.append(tmpl_tr_b + "[" + udl["display-name"] +"](" + fl_link + ")" + tmpl_td + author + tmpl_td + udl["description"] + tmpl_td + ov_map + tmpl_tr_e)

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
    tab_text += tmpl_fl_head
    tab_text += tmpl_new_line.join(fl_list)
    print(f'- Number of FunctionLists referenced: {len(fl_list)}')

    # always end the file with a newline
    tab_text += tmpl_new_line

    return tab_text

def get_udl_internal_name(oUDL):
    udl_xml = oUDL['id-name'] + ".xml"
    filename_xml  = Path(os.path.join(os.getcwd(),"UDLs", udl_xml))
    if not filename_xml.exists():
        print(f'get_udl_internal_name("{udl_xml}"): TODO: need to handle web requests')
        return None

    # parse xml
    try:
        doc = etree.parse(filename_xml)
    except IOError:
        post_error(f'get_udl_internal_name("{filename_xml}"): IOError Invalid File')
        return None
    except etree.XMLSyntaxError as err:
        post_error(f'get_udl_internal_name("{filename_xml}"): {str(err.error_log)}: XMLSyntaxError Invalid File')
        return None
    except:
        post_error(f'get_udl_internal_name("{filename_xml}"): Unknown error. Maybe check that no xml version is in the first line.')
        return None

    element = doc.find(".//UserLang")
    if element is None:
        post_error(f'get_udl_internal_name("{filename_xml}"): no <UserLang> found')
        return None

    if not 'name' in element.attrib:
        post_error(f'get_udl_internal_name("{filename_xml}"): no <UserLang> found')
        return None

    name = element.get('name')
    #print(f'get_udl_internal_name("{filename_xml}"): found name="{name}"' )

    return name

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
    tLastGH = time.time()

    print("\nParsing %s" % filename)

    for udl in udlfile["UDLs"]:
        print("- " + udl["display-name"])

        # false fail from PR #317 should have been caught by a github repo that wasn't using raw URL, but didn't
        #   so my other checks still weren't enough
        if udl["repository"] != "" and "github.com" in udl["repository"]:
            post_error(f"URL:{udl['repository']} should use raw.githubusercontent.com instead")
            continue

        try:
            if udl["repository"] != "" :
                if "github.com" in udl["repository"]:
                    print(f"GH Repo: {udl['repository']} @ {time.time()} vs {tLastGH}\n")
                    if time.time()-tLastGH<1.0:
                        time.sleep(1.0)
                    tLastGH = time.time()
                response = requests.get(udl["repository"])
        except requests.exceptions.RequestException as e:
            post_error(str(e))
            continue

        if udl["repository"] != "" and response.status_code == 429:
            tWait = 0.1
            if 'retry-after' in response.headers:
                tWait = int(response.headers['retry-after'])
            time.sleep(tWait)
            try:
                response = requests.get(udl["repository"])
            except requests.exceptions.RequestException as e:
                post_error(str(e))
                continue

        # false fail from PR #317
        if udl["repository"] != "" and response.status_code != 200:
            post_error(f'{udl["display-name"]}: failed to download udl from repository="{udl["repository"]}". Returned code {response.status_code}')
            post_error(response.headers)
            continue

        # Issue#307=TODO: check for XML Content-Type or at least XML extension
        if udl["repository"] != "":
            isXML = False
            ct = response.headers["content-type"]
            if ct[-4:]=="/xml": isXML = True
            if udl["repository"][-4:]==".xml": isXML = True
            if not isXML:
                msg = f'UDL({udl["display-name"]}) => {udl["repository"]} => Content-Type: {ct}:\r\n\tThe REPOSITORY needs to be a link to a valid XML file'
                abs_path = Path(os.path.join(os.getcwd(),"UDLs", udl["id-name"]+".xml"))
                if abs_path.exists():
                    msg += f'\n{abs_path} exists in Repo; JSON could use "repository": "",'
                post_error(msg)

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
            if udl["autoCompletion"]:
                udl_internal_name = get_udl_internal_name(udl)      # this name will also be used for autoCompletion validation
                udl["_autoCompletion_internal"] = udl_internal_name

                if udl_internal_name is None:
                    post_error(f'{udl["display-name"]}: autoCompletion name check could not find <UserLang name="..."> for comparison')
                else:
                    # add mapping id2ac and vice versa
                    if "id2ac" not in udlfile:
                        udlfile["id2ac"] = {}
                    udlfile["id2ac"][udl['id-name']] = udl_internal_name
                    udlfile["id2ac"][udl['id-name'].casefold()] = udl_internal_name
                    udlfile["id2ac"][udl_internal_name] = udl['id-name']
                    udlfile["id2ac"][udl_internal_name.casefold()] = udl['id-name']

                if str(udl["autoCompletion"]) == "True":
                    if udl_internal_name is None:
                        # autoCompletion defaults to display-name, not id-name
                        ac_link = udl["display-name"] + ".xml"
                    else:
                        ac_link = udl_internal_name + ".xml"

                        # audit internal name vs display-name, which are required to match for autoCompletion
                        if udl_internal_name != udl["display-name"]:
                            post_error(f'{udl["display-name"]}: JSON:{{"autoCompletion": true}}, but XML:<UserLang name="{udl_internal_name}"> is different than JSON:{{"display-name": "{udl["display-name"]}"}}, so please fix to have JSON:{{"display-name": "{udl_internal_name}"}} to match')
                            sys.exit(-2)
                elif udl["autoCompletion"][0:4] == "http":
                    ac_link = udl["autoCompletion"]
                else:
                    if udl_internal_name is None:
                        ac_link = str(udl["autoCompletion"]) + ".xml"
                    else:
                        ac_link = udl_internal_name + ".xml"

                        # audit internal name vs display-name name: recommend to match
                        if udl_internal_name != udl["display-name"]:
                            print(f'  !! XML:<UserLang name="{udl_internal_name}"> is different than JSON:{{"display-name": "{udl["display-name"]}"}}: CONTRIBUTING.md recommends those two should match if possible !!')

                    # audit internal name vs autoCompletion text name: MUST match
                    if udl_internal_name.casefold() != udl["autoCompletion"].casefold():
                        post_error(f'{udl["display-name"]}: autoCompletion file name mismatch: JSON indicates filename="{udl["autoCompletion"]}.xml" but N++ autoCompletion naming rules requires it at filename="{ac_link}"')
                        sys.exit(-2)
                ac_link_abs  = Path(os.path.join(os.getcwd(),"autoCompletion", ac_link))
                udl["_ac_link"] = ac_link
                udl["_ac_link_abs"] = ac_link_abs

                if ac_link[0:4] == "http":
                    try:
                        response = requests.get(ac_link)
                        print(f'  + also confirmed autoCompletion URL: {ac_link}')
                        # Issue#307=TODO: check for XML Content-Type
                    except requests.exceptions.RequestException as e:
                        post_error(str(e))
                        continue

                    isXML = False
                    ct = response.headers["content-type"]
                    if ct[-4:]=="/xml": isXML = True
                    if udl["repository"][-4:]==".xml": isXML = True
                    if not isXML:
                        msg = f'AC({udl["display-name"]}) => {ac_link} => Content-Type: {ct}:\r\n\tThe "autoCompletion" link needs to be a valid XML file'
                        post_error(msg)
                elif not ac_link_abs.exists():
                    post_error(f'{udl["display-name"]}: autoCompletion file missing from repo: JSON id-name expects it at filename="autoCompletion/{ac_link}" (previously expected filename="autoCompletion/{udl["id-name"]}.xml", which might be culprit)')
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

                if len(fl_link)>4 and fl_link[0:4] == "http":
                    try:
                        response = requests.get(fl_link)
                        print(f'  + also confirmed functionList URL: {fl_link}')
                        # Issue#307=TODO: check for XML Content-Type
                    except requests.exceptions.RequestException as e:
                        post_error(str(e))
                        continue
                    isXML = False
                    ct = response.headers["content-type"]
                    if ct[-4:]=="/xml": isXML = True
                    if udl["repository"][-4:]==".xml": isXML = True
                    if not isXML:
                        msg = f'FL({udl["display-name"]}) => {ac_link} => Content-Type: {ct}:\r\n\tThe "functionList" link needs to be a valid XML file'
                        post_error(msg)
                elif not fl_link_abs.exists():
                    post_error(f'{udl["display-name"]}: functionList file missing from repo: JSON id-name expects it at filename="functionList/{fl_link}"')
                else:
                    print(f'  + also confirmed "functionList/{fl_link}"')

                sfile = None
                if not 'sample' in udl: # doesn't exist
                    post_error(f'{udl["display-name"]}: functionList file requires sample filefilename="functionList/{fl_link}"')
                elif not udl['sample']:   # exists but not true
                    post_error(f'{udl["display-name"]}: functionList file requires sample filefilename="functionList/{fl_link}"')
                elif str(udl['sample']) == 'True':
                    sfile = udl["id-name"]
                else:
                    sfile = str(udl['sample'])

                if sfile:
                    # verify sample UDL file exists
                    spath = Path(os.path.join(os.getcwd(),"UDL-samples", sfile))
                    if len(sfile)>4 and sfile[0:4] == 'http':
                        try:
                            response = requests.get(sfile)
                            print(f'  + also confirmed sample-file URL: {sfile}')
                        except requests.exceptions.RequestException as e:
                            post_error(str(e))
                    elif not spath.exists():
                        post_error(f'{udl["display-name"]}: functionList UDL-sample file missing from repo: JSON id-name expects it at filename="UDL-samples/{sfile}"')
                    else:
                        print(f'  + also confirmed "UDL-samples/{sfile}"')

                    # verify Test directory exists for this UDL+FL
                    testDir = Path(os.path.join(os.getcwd(), "Test", "functionList", udl['id-name']))
                    if not testDir.exists():
                        post_error(f'{udl["display-name"]}: functionList Test directory missing from repo: JSON id-name expects it at filename="{testDir}"')
                        continue

                    # verify expected-results file exists for this UDL+FL
                    expectFile = Path(os.path.join(os.getcwd(), "Test", "functionList", udl['id-name'], "unitTest.expected.result"))
                    if not expectFile.exists():
                        post_error(f'{udl["display-name"]}: functionList Test directory missing expected results: JSON id-name expects it at filename="{expectFile}"')
                        continue

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
