#!/usr/local/bin/python3

import json
import os
import io
import sys
import shutil
import inspect
from timeit import default_timer as timer
import subprocess

api_url = os.environ.get('APPVEYOR_API_URL')
has_error = False

bin_dir = sys.argv[1] if sys.argv[1] else './PowerEditor/bin'
npp = os.path.join(bin_dir, 'notepad++.exe')

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

def json_to_unitTest_launcher():
    udlfile = json.loads(open("../udl-list.json", encoding="utf8").read())

    # generate a map to determine which ids have ac, fl, and/or udls
    print("\nLook for functionList definitions in %s" % udlfile["name"])
    for udl in udlfile["UDLs"]:
        id_str = udl["id-name"]

        # print("- %s" % id_str)

        if 'functionList' in udl:
            fl = udl['functionList']
            if not fl: next     # do nothing if it's non-true


            print("+ found functionList for %s" % udl['id-name'])
            #print(json.dumps({"UDL+FL Info": udl}, sort_keys=True, indent=2, separators=(',',':')))

            if fl == True:
                fl = id_str

            ufile = os.path.join('..', 'UDLs', id_str + ".xml")
            if not os.path.exists(ufile):
                ufile = udl['repository']
            if not os.path.exists(ufile) and not(len(ufile)>4 and ufile[0:4] == 'http'):
                post_error("Could not resolve %s" % ufile)

            umap = { 'id': udl['id-name'], 'display': udl['display-name'] }

            umap['udl'] = {
                'src': ufile,
                'dst': os.path.join(bin_dir, "userDefineLangs", id_str + ".xml")
            }

            umap['om'] = {
                'dst': os.path.join(bin_dir, "functionList", "overrideMap.xml")
            }

            srcFl = fl
            if not(len(fl)>4 and fl[0:4] == 'http'):
                srcFl = os.path.join('..', 'functionList', fl + ".xml")

            umap['fl'] = {
                'src': srcFl,
                'dst': os.path.join(bin_dir, "functionList", fl + ".xml")
            }

            smpFile = udl['sample']
            umap['sample'] = {
                'dst': os.path.join('functionList', id_str, 'unitTest')
            }
            if len(smpFile)>4 and smpFile[0:4]=='http':
                post_error("TODO: don't know how to download %s yet" % (smpFile))
                umap['sample']['src'] = None  # TODO: the path to the file saved from download
            elif smpFile:
                umap['sample']['src'] = os.path.join('..', 'UDL-samples', smpFile)

            umap['output'] = {
                'exp': os.path.join('functionList', id_str, 'unitTest.expected.result'),
                'got': os.path.join('functionList', id_str, 'unitTest.result.json')
            }


            #print(json.dumps(umap, sort_keys=True, indent=2, separators=(',',':')))

            for k in ('udl', 'fl', 'sample'):
                src = umap[k]['src']
                dst = umap[k]['dst']
                if os.path.exists(src):
                    print("  + Copy %s to %s" % (src, dst))
                    shutil.copy(src, dst)
                elif len(src)>4 and src[0:4]=='http':
                    post_error("TODO: don't know how to download %s to %s" % (src, dst))
                    src = None  # TODO: the path to the file saved from download
                else:
                    post_error("Could not copy %s to %s" % (src, dst))

            omTxt = """<?xml version="1.0" encoding="UTF-8" ?>
                <NotepadPlus>
                    <functionList>
                        <associationMap>
                            <association id="%s" userDefinedLangName="%s"/>
                        </associationMap>
                    </functionList>
                </NotepadPlus>
                """ % (id_str + '.xml', udl['display-name'])
            print("  + Generate %s" % (umap['om']['dst']))
            with open(umap['om']['dst'], 'w') as f:
                f.write(inspect.cleandoc(omTxt))

            if not has_error:
                one_err = run_unit_test(umap)

            # delete generated files
            for k in ('udl', 'fl', 'om', 'sample'):
                dst = umap[k]['dst']
                if os.path.exists(dst):
                    print("  - Remove %s" % (dst))
                    os.remove(dst)

            if not one_err:
                dst = umap['output']['got']
                if os.path.exists(dst):
                    print("  - Remove %s" % (dst))
                    os.remove(dst)

def run_unit_test(umap):
    """Launch notepad++.exe with -export=functionList and process the output"""
    t0 = timer()
    print("  * Running unit test on %s:" % (umap['id']))
    # print(json.dumps(umap, sort_keys=True, indent=2, separators=(',',':')))
    cmd_str = '"%s" -multiInst -nosession -export=functionList -udl="%s" "%s"' % (npp, umap['display'], umap['sample']['dst'])
    cmpl = subprocess.run(cmd_str)
    print("    => exported functionList in %.1fms, returning %d" % ( (timer()-t0)*1000, cmpl.returncode))
    try:
        with open(umap['output']['exp']) as f:
            exp = f.read().replace('\r\n', '\n').rstrip('\n')
        with open(umap['output']['got']) as f:
            got = f.read().replace('\r\n', '\n').rstrip('\n')

        if got == exp:
            print("    => compare OK")
            return False
        else:
            print("    => compare MISMATCH")
            post_error("functionList export got:\n%s\nvs expected:\n%s" % (got, exp))
    except Error as e:
        post_error("    => error while comparing %s to %s: %s" % (umap['output']['got'], umap['output']['exp'], str(e)))

    return True

# verify it finds notepad++.exe
print("npp = %s" % npp)
if not os.path.exists(npp):
    post_error("could not find %s" % npp)
    sys.exit(-2)

# copy the files to the right place for FunctionList UnitTesting
json_to_unitTest_launcher()


if has_error:
    sys.exit(-2)
else:
    sys.exit()
