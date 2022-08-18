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
   - From the file's page, click on either the "Raw" button (which will take you to a page where you can copy/paste the raw contents), or even easier, just click on the copy raw contents button, which will immediately place the raw contents in your clipboard for pasting.
       ![image](https://user-images.githubusercontent.com/17455758/185504202-754541f7-ee6f-4e77-9a6b-2338448e0dfa.png)
   - Do not just right click to try to download the file from either the [`UDL list`](./udl-list.md) or the [directory listing on GitHub](https://github.com/notepad-plus-plus/userDefinedLanguages/tree/master/UDLs), as either of those right-click actions will download the GitHub web page for that file (which is not the UDL's XML file and will not work).
2. Import the file by placing the file in your `userDefineLangs` folder and restarting Notepad++.  (It is also possible to use the User Defined Language dialog box and click **Import**, but that method is the "old way" and is no longer recommended: it's more steps, and harder to maintain, so there is no good reason to do it that way).  More details of what those steps entail can be found in the ["Import a UDL" section](https://npp-user-manual.org/docs/user-defined-language-system/#import-a-udl) of the official documentation.
3. If the UDL author provided an sample file that uses that UDL, you may download that from the `UDL-samples` folder of the repository.
4. If the UDL author provided an autoCompletion XML file for that UDL, you may download it from the `autoCompletions` folder of the repository, and put it in the `autoCompletion\` sub-folder of your Notepad++ installation directory.  More details can be found in the online User Manual in the ["autoCompletion"](https://npp-user-manual.org/docs/auto-completion/) and ["configuration files details"](https://npp-user-manual.org/docs/config-files/#other-configuration-files) sections.

## Submitting your UDL to the Collection

You can submit your UDL file(s) into this repo, or a (some) link(s) to where your UDL file(s) is (are) hosted.
In both cases, you have to do a Pull Request on this repository. 

More information about submitting your UDL to the Collection, please refer to:

https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/CONTRIBUTING.md

We populated the initial UDLs in this Collection based on the old NppWiki++ list of UDLs (archived at [archive.org](https://web.archive.org/web/20180814202307/http://docs.notepad-plus-plus.org/index.php/User_Defined_Language_Files))

The original author of any UDL in this Collection may [request](https://github.com/notepad-plus-plus/userDefinedLanguages/issues) that we remove it from the Collection (or submit a PR to do the same), and we will oblige.
