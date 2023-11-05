#!/usr/local/bin/python3

import json
import os
import io
import sys

import requests
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

def gen_pl_table(filename):
    try:
        udlfile = json.loads(open(filename, encoding="utf8").read())
    except ValueError as e:
        post_error(filename + " - " + str(e))
        return

    tab_text = "## UDL Definitions%s%s" % (tmpl_new_line, tmpl_new_line)
    # tab_text += "version %s%s" % (udlfile["version"], tmpl_new_line)
    tab_text += tmpl_tab_head

    ac_list = []

    # UDL Name = (ij.display-name)ij.id-name.xml or repolink
    # Author = ij.author
    # Description = " <details> <summary> " + first_two_lines(ij.description) + " </summary> " rest_of_text(ij.description) +"</details>"
    for udl in sorted(udlfile["UDLs"], key=lambda d: d['display-name'].casefold()):
        # link to either repo or local copy of XML
        udl_link = udl["repository"]
        if not udl_link:
            udl_link = "./UDLs/" + udl["id-name"] + ".xml"

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

        # if this entry has autoCompletion defined, add it to the list of autoCompletions
        if "autoCompletion" in udl:
            if udl["autoCompletion"]:
                if str(udl["autoCompletion"]) == "True":
                    ac_link = udl["id-name"] + ".xml"
                elif udl["autoCompletion"][0:4] == "http":
                    ac_link = udl["autoCompletion"]
                else:
                    ac_link = str(udl["autoCompletion"]) + ".xml"

                print(f'autoCompletion: {udl["autoCompletion"]} => {ac_link}')
                # absolute path for existence testing
                ac_link_abs  = Path(os.path.join(os.getcwd(),"autoCompletions", ac_link))

                # relative path for correct linking
                ac_link = "./autoCompletions/%s" % (ac_link)

                # TODO: use autoCompletionAuthor field if the autoCompletion has a different author than the UDL (like for RenderMan)
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

    # add the Auto-Completion Definitions in a separate table at the end
    tab_text += tmpl_new_line
    tab_text += "## Auto-Completion Definitions%s%s" % (tmpl_new_line, tmpl_new_line)
    tab_text += tmpl_tab_head
    tab_text += tmpl_new_line.join(ac_list)

    return tab_text

with open("udl-list.md", "w", encoding="utf8") as md_file:
    md_file.write(gen_pl_table("udl-list.json"))

if has_error:
    sys.exit(-2)
else:
    sys.exit()
