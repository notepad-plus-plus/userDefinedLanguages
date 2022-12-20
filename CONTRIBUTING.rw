The goal of this Collection is to provide a UDL center for users who need the programming languages which are not supported directly by Notepad++. Any UDL author can submit their UDL (with an explicit name - "id-name") in `UDLs` directory so users can find what they want from `UDLs` directory very easily.  However, it is possible that some UDL authors prefer to keep files in their repository rather than submitting files into official User Defined Languages repository (https://github.com/notepad-plus-plus/userDefinedLanguages/UDLs/). They can still submit the URL of their UDL in question.

In both cases you have to modify [udl-list.json](https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/udl-list.json) and [udl-list.md](https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/udl-list.md), submit a Pull Request to add it to the Collection. The team will review your submission, and either merge it into the Collection, ask for clarification or fixes, or reject the submission.


## Some rules and recommendation of submission

To be accepted, your submission _must_ meet the following **requirement**s and _should_ meet the following **recommendations**
1. **requirement**: The language being described by the UDL shoud be of reasonably-general interest.
   * Example: a UDL for a Markdown variant would be of general interest
   * Example: a UDL for the programming language that you invented for your computer science class that only you and a few classmates will use is not likely of general interest (unless you happen to have invented the Next Big Language).
2. **requirement**: The XML file must be given a unique name, because of the file structure.  The name must include the name of the language, but also something else to make it unique.  Possibilities of the extra include
   * The theme the color scheme was built to match.  Example: `Markdown_ThemeChoco.udl.xml` should match the "Choco" theme
   * The variant of the language.  Examples: `Markdown_DaringFireball.udl.xml` vs `Markdown_CommonMark.udl.xml` for two variants implementatinos of Markdown with different extended syntax.
   * The author's name.  Example: `STL_udl.byPryrt.xml`, if Pryrt was not creative enough to come up with a better description of his UDL for the STL syntax highlighting.
   * Use underscores or hyphens or periods to separate words, not spaces.
3. **recommendation**: each submitted UDL file should only contain one lanugage it is defining.  This will make it easier for users to only download what they need.
   * A possible exception might be if you are bundling multiple UDL for related languages all using the same theme.  Example: `3dModeling_bundle_forChocoTheme_includes_STL_OBJ_3DS.udl.xml` would implement highlighting rules for the three 3D modeling formats of STL, OBJ, and 3DS, all for the same Choco theme.
4. **recommendation**: if your UDL file only contains one language, the `display-name` attribute in the JSON file (described below) should have the same value as the `<UserLang name="...">` inside your definition file.  This will keep the name in the **Language** menu the same as the name that was shown in the download tool (coming soon).
5. **recommendation**: in your Pull Request, please provide a link to a public description of the language your UDL is based on (which will help to establish the general-interest nature of the UDL), as well as a link to an example file in that language (so that the UDL can be verified as functional).
   * If you have an example file, you can upload it to the `UDL-samples` folder of the repository. Please have this file use the same name as your UDL definition file, but with the appropriate file extension, rather than `.xml`.  Example: `UDLs\STL_udl.byPryrt.xml` would have a corresponding example file `UDL-samples\STL_udl.byPryrt.stl`.
6. **recommendation**: if you have also created an [autoCompletion file](https://npp-user-manual.org/docs/auto-completion/) for your UDL, you may add it in the `autoCompletions` folder before you submit your PR, using a similar naming scheme to the UDL's XML filename. 

## Edit `udl-list.json`

When you make a submission, you should edit the [udl-list.json](https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/udl-list.json) file, following these definitions:
* The `id-name` attribute will match the name of the UDL file, without the `.xml`.
* The `display-name` attribute will match the `<UserLang name="...">` from the submitted UDL file, if possible.
* The `version` attribute can have a `v1.00`-style version or just a last-edited date like `2020-Jan-12`.
* The `repository` attribute will be left blank for UDL files uploaded to this repository; if the UDL resides in an external repository (or if you want to add a link to the original source file, but still keep a copy in this repository), use this attribute to hold the full URL of the external file
* The `description` attribute is an optional description of the UDL language (it could be the based on the `id-name` or `display-name`, but with spaces instead of underscores, hyphens, and/or periods).
* The `author` attribute should be your name or GitHub username or email address.
* The `homepage` attribute could be a link to your GitHub repository for the UDL language or your GitHub user page.


## Edit `udl-list.md`

[udl-list.md](https://github.com/notepad-plus-plus/userDefinedLanguages/blob/master/udl-list.md) is UDL user interface file which shows all available UDL files and their location (URL) so user can download needed UDL directly from it.
* `Name` : The name of the UDL (based on the `display-name` attribute from above).  This should be input as a Markdown link to the main file: the text of the link should be the language name; the URL should point to the uploaded (or external) UDL XML file.
* `Description` : The details of this UDL: most likely, the same as the `description` attribute from above.
* `Author` : Author name.  If the `homepage` is known, the author's name should link to the `homepage` of the author.

## Validation

The maintenance team will be checking the UDL file and both udl-list.json & udl-list.md or conformance to these requirements. By submitting the Pull Request, you are giving permission for edits to help it match the requirements. If you need help with the JSON, please ask for help in the Pull Request, and be willing and available to answer questions for clarifications so that you can be helped.

## HOW TO Submit Pull Request

Since many contributors are not GitHub experts, we have added in this section to make it easier for you to submit your files in a Pull Request (PR)

0. Create a GitHub account 
   - Without an account, you cannot submit a PR
2. Create a **fork** of the userDefinedLanguages Collection
   - Click the **Fork** label/icon from the [main UDL Collection page](https://github.com/notepad-plus-plus/userDefinedLanguages)
   - ![image](https://user-images.githubusercontent.com/17455758/191838275-f4237476-0e99-45f7-8bc7-251e8936f1d3.png)
   - If you already have a fork, use **Sync Fork > Update Branch** to make sure your fork is up-to-date with the main Collection
3. Make your changes:
   - Upload the UDL's XML file to the UDL folder _in your fork_, named per the rules defined above
   - Edit the `udl-list.md` and `udl-list.json` _in your fork_, per the rules defined above
4. Create a PR from your fork
    - from your fork's master branch, after you've made the changes above,
    - click the down arrow on **Contribute** 
    - select **Open Pull Request**
    - fill out your description for the PR, and submit the PR
