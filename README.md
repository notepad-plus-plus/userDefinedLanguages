# Notepad++ User Defined Languages Collection

Notepad++ supports around 80 programming languages for syntax highlighting & folding.  For languages that are not in the list of languages with built-in support, someone may have created a User Defined Language (UDL) for adding syntax highlighting to the language and added it to this collection, or you can submit a UDL to this collection for others to use. 

To learn all about User Defined Languages:

https://npp-user-manual.org/docs/user-defined-language-system/

Here is the UDL list and from where you can download:

https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/udl-list.md

## Using a UDL from this Collection

For now, you have to manually install a new User Defined Language.

1. Download the XML file from the [`UDL list`](./udl-list.md) of this Collection.
   - From the [`UDL list`](./udl-list.md), click on the name of the file.
   - From the file's page, there are two buttons (the "Raw" button on the left, or the double-square icon farther right): either of these buttons can be used to get the actual XML contents, but they behave slightly differently
       <br>![image](https://user-images.githubusercontent.com/17455758/185504202-754541f7-ee6f-4e77-9a6b-2338448e0dfa.png)
       - Choice 1: If you click on the button on the left, it will open up a plain-text page in the web browser, which shows the raw XML text for the UDL.
           <br>![image](https://user-images.githubusercontent.com/17455758/193082422-d9c68744-c840-44c4-9e08-85f93985c960.png)
           - From the resulting screen, you can either 
               - copy the text, and paste it into a new file in Notepad++, and save it as an XML file to a known location (or directly to the `userDefineLangs` folder in step 2)
               - or you can use your browser's **Right Click > Save As...** feature to save it in a known location (or directly to the `userDefineLangs` folder in step 2)
       - Choice 2: If you click on the button on the right, the raw contents will be in the clipboard
           <br>Pressing this icon ![image](https://user-images.githubusercontent.com/17455758/193082624-c67b4c77-35bd-4386-9d83-b882e0208565.png) will make it process briefly, then become this new icon ![image](https://user-images.githubusercontent.com/17455758/193084173-b36a8d5d-f057-4d89-98a8-c98e8a7f331d.png)
           - The contents of your clipboard are now the raw XML contents of the file.
           - You can paste these contents into a new document in Notepad++, and save it to a known location (or directly to the `userDefineLangs` folder in step 2)
   - Do not just right click to try to download the file from either the [`UDL list`](./udl-list.md) or the [directory listing on GitHub](https://github.com/notepad-plus-plus/userDefinedLanguages/tree/master/UDLs), as either of those right-click actions will download the GitHub web page for that file (which HTML, and _not_ the UDL's XML file and will _not_ work).
2. Import the file by placing the file in your `userDefineLangs` folder.  
    - You can use Notepad++'s **Language > User Defined Language > Open User Defined Language folder...** menu entry to easily find the right folder to place your XML file
    - It is alternately possible to use the **User Defined Language** dialog box and click **Import**, but that method is the "old way" and is no longer recommended: it makes it harder to maintain (because it puts all UDLs in a single file, instead of using a separate file for each UDL), so it is no longer recommended.
    - More details of what those steps entail can be found in the ["Import a UDL" section](https://npp-user-manual.org/docs/user-defined-language-system/#import-a-udl) of the official documentation.
3. Restart Notepad++
    - Without this restart, Notepad++ will not know about the new UDL.
4. If the UDL author provided an autoCompletion XML file for that UDL, you may download it from the `autoCompletions` folder of the repository (using similar download procedure as described in step 1 above), and put it in a file in the `autoCompletion\` sub-folder of your Notepad++ installation directory.  More details can be found in the online User Manual in the ["autoCompletion"](https://npp-user-manual.org/docs/auto-completion/) and ["configuration files details"](https://npp-user-manual.org/docs/config-files/#other-configuration-files) sections.
5. If the UDL author provided an sample file that uses that UDL, you may download that from the `UDL-samples` folder of the repository.  If you open that sample in Notepad++ after the restart from step 3.

## Submitting your UDL to the Collection

You can submit your UDL file(s) into this repo, or a (some) link(s) to where your UDL file(s) is (are) hosted.
In both cases, you have to do a Pull Request on this repository. 

More information about submitting your UDL to the Collection, please refer to:

https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/CONTRIBUTING.md

We populated the initial UDLs in this Collection based on the old NppWiki++ list of UDLs (archived at [archive.org](https://web.archive.org/web/20180814202307/http://docs.notepad-plus-plus.org/index.php/User_Defined_Language_Files))

The original author of any UDL in this Collection may [request](https://github.com/notepad-plus-plus/userDefinedLanguages/issues) that we remove it from the Collection (or submit a PR to do the same), and we will oblige.
