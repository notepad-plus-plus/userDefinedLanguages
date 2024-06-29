cd Test

$PowerEditorSource = "c:\Program Files\Notepad++\"
$PowerEditorLocal = ".\PowerEditor"

if ( !(Test-Path $PowerEditorLocal) ) {
	# to be more efficient, only copy from PowerEditorSource if we
	# don't already have the PowerEditorLocal hierarchy
	# (that also lets me keep a customized local
	Copy-Item "$PowerEditorSource" -Destination "$PowerEditorLocal\bin" -Recurse -Force
}
New-Item "$PowerEditorLocal\bin\doLocalConf.xml" -ea 0 > $nul
New-Item "$PowerEditorLocal\bin\userDefineLangs" -ItemType Directory -ea 0 > $nul
python doUnitTests.py $PowerEditorLocal\bin

cd ..
