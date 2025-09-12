# generate autoCompletion files for languages that do not have any

import os
import sys
import json
from datetime import datetime
from lxml import etree
gHasError = False

def post_error(msg, immediate=False):
    message = {
        "message": msg,
        "category": "error"
    }

    print(json.dumps(message, indent=4))

    gHasError = True

    if immediate:
        sys.exit(-2)

def checkEachUdl(filename):
    udl_list = json.load(open(filename, encoding="utf8"))

    for udl in udl_list["UDLs"]:
        if 'autoCompletion' in udl:
            continue

        xinfo = getUdlInfoAndKeywords(udl)
        if xinfo is None:
            continue


        if xinfo['keywords'] is None or len(xinfo['keywords'])==0:
            # don't generate autoCompletion for this UDL if there are no keywords
            print(f"checkEachUdl() => Skipping {xinfo['udl_internal_name']}: No keywords found in UDL, so no KeyWords for autoCompletion")
            continue

        # print(xinfo["udl_internal_name"] + " => " + json.dumps(sorted(xinfo['keywords'], key=str.casefold), indent=2)); sys.exit(0)

        createAutoCompletion(xinfo)

        udl['autoCompletion'] = xinfo["udl_internal_name"]
        udl['autoCompletionAuthor'] = 'generate_ac.py'

        #print(json.dumps(udl, indent=4))

    #print(json.dumps(udl_list, indent=4))

    json.dump(udl_list, open(filename, 'w', encoding="utf8"), indent=4)

def getUdlInfoAndKeywords(udl):
    xinfo = dict()

    # don't create local AC for a remote UDL
    if 'repository' in udl and udl['repository'][0:4] == 'http':
        return None

    # make sure UDL XML file exists
    udl_filename = f"./UDLs/{udl['id-name']}.xml"
    if not os.path.exists(udl_filename):
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): File does not exist')
        return None

    # parse the UDL XML
    try:
        udl_doc = etree.parse(udl_filename)
    except IOError:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): IOError Invalid File')
        return None
    except etree.XMLSyntaxError as err:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): {str(err.error_log)}: XMLSyntaxError Invalid File')
        return None
    except:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): Unknown error. Maybe check that no xml version is in the first line.')
        return None

    # Get the UserLang element
    el_userlang = udl_doc.find(".//UserLang")
    if el_userlang is None:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): no <UserLang> found')
        return None

    # Extract the name attribute from <UserLang>
    if not 'name' in el_userlang.attrib:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): no <UserLang> found')
        return None

    xinfo["udl_internal_name"] = el_userlang.get('name')

    # Get the Prefix information
    el_prefix = el_userlang.find('.//Prefix')
    prefix = dict(Keywords1="no",Keywords2="no",Keywords3="no",Keywords4="no",Keywords5="no",Keywords6="no",Keywords7="no",Keywords8="no")
    if el_prefix is None:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): could not find <Prefix> element')
        return None

    #print(f'{xinfo["udl_internal_name"]}:: found {etree.tostring(el_prefix).decode("utf-8")}')
    for key in prefix.keys():
        if key in el_prefix.attrib:
            prefix[key] = el_prefix.get(key)
    #print(f'{xinfo["udl_internal_name"]}:: prefixes: {prefix}')

    # Find the <KeywordLists> element
    el_kwlists = el_userlang.find('.//KeywordLists')
    if el_kwlists is None:
        post_error(f'getUdlInfoAndKeywords("{udl_filename}"): no <KeywordLists> found')
        return None

    # Iterate through the <Keywords> elements, looking for name="Keywords#", and adding those to the extracted list of keywords
    kw_list = []
    for kw in el_kwlists.iter('Keywords'):
        # element must have name attribute, otherwise cannot determine whether it's a keyword list
        if not 'name' in kw.attrib:
            continue

        kw_name = kw.get('name')

        # if it's not Keywords*, and if the * isn't a digit, then don't try to add these keywords
        if kw_name[0:8] != 'Keywords' or not kw_name[8].isdigit():
            continue

        # don't try to add empty keyword lists
        if kw.text is None:
            continue

        # don't try tot add to keyword list if we cannot determine whether it's a prefix or not
        if not kw_name in prefix:
            continue

        # add to keyword list if this element isn't in prefix mode
        if prefix[kw_name].lower() == "no":
            kw_list += kw.text.split()

    if len(kw_list) == 0:
        kw_list = None  # need to indicate that it found no keywords, at which point, it shouldn't try to generate the AC file...

    xinfo['keywords'] = kw_list

    return xinfo

def createAutoCompletion(xinfo):
    ac_path = f'.\\autoCompletion\\{xinfo["udl_internal_name"]}.xml'

    if os.path.exists(ac_path):
        # skip existing AC files (at least for now)
        return None

    print(f'createAutoCompletion() => "{ac_path}"')

    xroot = etree.Element("NotepadPlus")

    xcom = etree.Comment(f" '{xinfo['udl_internal_name']}' autoCompletion definition automatically generated from UDL keyword lists by generate_ac.py on {datetime.now().strftime('%Y-%m-%d')} ")
    xroot.append(xcom)
    xcom = etree.Comment(f" Default values automatically generated, and have no knowledge of the actual constructs for this particular language. ")
    xroot.append(xcom)
    xcom = etree.Comment(f" This is a starting point, and should be improved into a full autoCompletion with function parameter hints, etc, by an expert in this language. ")
    xroot.append(xcom)
    xcom = etree.Comment(f" If you are such an expert, please remove these comments and submit your updates back to the UDL Collection. Thank you. ")
    xroot.append(xcom)

    xac = etree.SubElement(xroot, "AutoComplete", language=xinfo["udl_internal_name"])

    xcom = etree.Comment(f" Environment: Change start/stopFunc, paramSeparator, and terminal as needed ")
    xac.append(xcom)
    xenv = etree.SubElement(xac, "Environment", ignoreCase="no", startFunc="(", stopFunc=")", paramSeparator=",", terminal="", additionalWordChar="")

    xcom = etree.Comment(f" KeyWords: generator assumes all keywords are _not_ functions ")
    xac.append(xcom)

    #print(etree.tostring(xroot, pretty_print=True, xml_declaration=True, encoding='utf-8').decode())

    for kw in sorted(xinfo["keywords"]):
        xkw = etree.SubElement(xac, "KeyWord", name=kw, func="no")

    etree.ElementTree(xroot).write(ac_path, pretty_print=True, xml_declaration=True, encoding='utf-8')

checkEachUdl('udl-list.json')

if gHasError:
    sys.exit(-1)
