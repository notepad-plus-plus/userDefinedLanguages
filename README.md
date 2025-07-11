# Notepad++ User Defined Languages Collection

Notepad++ supports around 80 programming languages for syntax highlighting & folding.  For languages that are not in the list of languages with built-in support, someone may have created a User Defined Language (UDL) for adding syntax highlighting to the language and added it to this collection, or you can submit a UDL to this collection for others to use.

To learn all about User Defined Languages:

https://npp-user-manual.org/docs/user-defined-language-system/

Here is the UDL list and from where you can download:

https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/udl-list.md

## Using a UDL from this Collection

### Easy Way: CollectionInterface Plugin

You can use the [CollectionInterface plugin](https://github.com/pryrt/NppPlugin-CollectionInterface/) to download and install UDLs (and associated files) from the UDL Collection:

1. If you haven't done so already, in Notepad++ v8.8.1 or newer, you can go to **Plugins > Plugins Admin**, checkmark `☑ CollectionInterface` , click **Install**.  After Notepad++ restarts, **Plugins** will have the **CollectionInterface** plugin.
2. **Plugins > CollectionInterface > CollectionInterface: Download**
3. Scroll through the UDL tab to see all the UDLs available:
   - Click on the UDL you want
   - if the selected UDL also has an associated AutoCompletion and/or FunctionList file, you can checkmark those options to grab them all at the same time.
       - (You can download the AutoCompletion or FunctionList files separately using the appropriate tabs in the **CollectionInterface: Download** dialog, but it's easier to just grab them all at the same time from the UDL tab)
4. Click **Download**.
5. After the progress bar reaches 100%, you can **Close**.
6. It will ask if you want to restart Notepad++ (which you need to do, in order for the UDL(s) to be available).

### Install Manually:

If you want to manually install a new User Defined Language from this collection.

1. Use Notepad++'s **Language > User Defined Language > Open User Defined Language folder...** menu entry to easily find the right `userDefineLangs\` folder to place your UDL definition file.  (You can copy the path from the file Explorer location bar, for pasting into the **Save As** dialog in step 2)
2. Download the XML file from the [`UDL list`](./udl-list.md) of this Collection.
   - From the [`UDL list`](./udl-list.md), click on the name of the file.
   - From the file's page, use the button labled "Raw" to open the source of the UDL.
       <br>![image](https://user-images.githubusercontent.com/17455758/193082422-d9c68744-c840-44c4-9e08-85f93985c960.png)
       <br>From that raw file, you can either:
       - you can use your browser's **Right Click > Save As...** feature to save the raw XML file to the `userDefineLangs\` folder found in step 1
       - copy the text of the file's contents, and paste it into a new file in Notepad++, and save it as an XML file to the `userDefineLangs\` folder found in step 1
   - **Warning:** Do not just right click to try to download the file from either the [`UDL list`](./udl-list.md) or the [directory listing on GitHub](https://github.com/notepad-plus-plus/userDefinedLanguages/tree/master/UDLs) links, as either of those right-click actions will download the GitHub web page for that file (which HTML, and _not_ the UDL's XML file and will _not_ work).
   - Alternatives to step 2 can be found in the ["Import a UDL" section](https://npp-user-manual.org/docs/user-defined-language-system/#import-a-udl) of the official online user manual.  But this version here is the easiest for those who haven't worked much with UDLs or GitHub.
3. Restart Notepad++
    - Without this restart, Notepad++ will not know about the new UDL.
4. If the UDL author provided an autoCompletion XML file for that UDL, you may download it from the `autoCompletions\` folder of the repository (using similar download procedure as described in step 2 above), and put it in a file in the `autoCompletion\` sub-folder of your Notepad++ installation directory.  More details can be found in the online User Manual in the ["autoCompletion"](https://npp-user-manual.org/docs/auto-completion/) and ["configuration files details"](https://npp-user-manual.org/docs/config-files/#other-configuration-files) sections.
5. If the UDL author provided a functionList XML file for that UDL, you may download it from the `functionList\` folder of the repository (using similar download procedure as described in step 2 above), and put it in a file in the `functionList\` sub-folder of your Notepad++'s `%AppData%\Notepad++\` or other configuration location (including that sub-folder in your installation directory).  More details can be found in the online User Manual in the ["functionList"](https://npp-user-manual.org/docs/function-list/) and ["functionList configuration files details"](https://npp-user-manual.org/docs/config-files/#function-list) sections. 
6. If the UDL author provided an sample file that uses that UDL, you may download that from the `UDL-samples\` folder of the repository.  If you open that sample in Notepad++ after the restart from step 3, it should apply the UDL highlighting.

## Submitting your UDL to the Collection

You can submit your UDL file(s) into this repo, or a (some) link(s) to where your UDL file(s) is (are) hosted.
In both cases, you have to do a Pull Request on this repository.

More information about submitting your UDL to the Collection, please refer to:

https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/CONTRIBUTING.md

We populated the initial UDLs in this Collection based on the old NppWiki++ list of UDLs (archived at [archive.org](https://web.archive.org/web/20180814202307/http://docs.notepad-plus-plus.org/index.php/User_Defined_Language_Files))

The original author of any UDL in this Collection may [request](https://github.com/notepad-plus-plus/userDefinedLanguages/issues) that we remove it from the Collection (or submit a PR to do the same), and we will oblige.

## What this Collection Is Not

This Collection is not for Feature Requests for the Notepad++ User Defined Language system.  If you would like improvements to how Notepad++ uses or implements UDLs, you will have to check if the [Notepad++ Issues](https://github.com/notepad-plus-plus/notepad-plus-plus/issues) already has an issue for your request, and if not, make the request there.  Any feature requests for the system made in the Collection's repository will be closed with a message that says it was requested in the wrong place.

The maintainers of this Collection do not have the knowledge to make a custom User Defined Language definition on request -- you likely know your Language much better that we do.  It is super simple to make your own UDL: paste your language's keywords into one or more of the eight keywords sections, put the appropriate operators into the operators inputs, possibly add some delimiters (like quote-pairs or parentheses pairs) and/or comments definitions and/or folding definitions; set the colors to match your desire, and enjoy.  You can see the online User Manual's [UDL description](https://npp-user-manual.org/docs/user-defined-language-system/) with the details on what all of those mean, and how to use it.  Once you have a working UDL, you can share it with others by [Contributing to the Collection](https://github.com/notepad-plus-plus/notepad-plus-plus/blob/master/CONTRIBUTING.md).  Any feature requests in this Collection's repository to "create the UDL definition for me" will be rejected: sorry.
