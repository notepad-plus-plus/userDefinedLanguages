# Notepad++ User Defined Languages Collection

Notepad++ supports around 80 programming languages for syntax highlighting & folding. If your beloved programming language is not in the supported language list, you may find it here. 

To learn all about User Defined Languages:

https://npp-user-manual.org/docs/user-defined-language-system/

## Using one of these User Defined Languages

For now, you have to manually install a new User Defined Language (UDL).

1. Download the XML file(s) from the [`UDLs`](./UDLs) folder of [this Collection](https://github.com/notepad-plus-plus/userDefinedLanguages).
2. Import the file(s) either by placing the file(s) in your `userDefineLangs` folder and restarting Notepad++, or by using the User Defined Language dialog box to **Import** your file(s).  More details of what those steps entail can be found in the ["Import a UDL" section](https://npp-user-manual.org/docs/user-defined-language-system/#import-a-udl) of the official documentation.

## Submitting your User Defined Language to the repository

If you have a User Defined Language XML file that you would like to share with the world, you can submit a Pull Request to add it to the Collection.  The team will review your submission, and either merge it into the Collection, ask for clarification or fixes, or reject the submission.

To be accepted, your submission _must_ meet the following **requirement**s and _should_ meet the following **recommendations**
1. **requirement**: The language being described by the UDL shoud be of reasonably-general interest.  
   * Example: a UDL for a Markdown variant would be of general interest
   * Example: a UDL for the programming language that you invented for your computer science class that only you and a few classmates will use is not likely of general interest (unless you happen to have invented the Next Big Language).
2. **requirement**: The XML file must be given a unique name, because of the file structure.  The name must include the name of the language, but also something else to make it unique.  Possibilities of the extra include
   * The theme the color scheme was built to match.  Example: `Markdown_ThemeChoco.udl.xml` should match the "Choco" theme
   * The variant of the language.  Examples: `Markdown_DaringFireball.udl.xml` vs `Markdown_CommonMark.udl.xml` for two variants implementatinos of Markdown with different extended syntax.
   * The author's name.  Example: `STL_udl.byPryrt.xml`, if Pryrt was not creative enough to come up with a better description of his UDL for the STL syntax highlighting.
3. **recommendation**: each submitted UDL file should only contain one lanugage it is defining.  This will make it easier for users to only download what they need.
   * A possible exception might be if you are bundling multiple UDL for related languages all using the same theme.  Example: `3dModeling_bundle_forChocoTheme_includes_STL_OBJ_3DS.udl.xml` would implement highlighting rules for the three 3D modeling formats of STL, OBJ, and 3DS, all for the same Choco theme.
4. **recommendation**: if your UDL file only contains one language, the JSON `display-name` attribute should have the same value as the `<UserLang name="...">` inside your definition file.  This will keep the name in the **Language** menu the same as the name that was shown in the download tool (coming soon).

... in progress ...
