cd Test

$PowerEditorSource = "c:\Program Files\Notepad++\"
$PowerEditorLocal = ".\PowerEditor"

if ( Test-Path $PowerEditorLocal ) {
	Remove-Item -Recurse -Force $PowerEditorLocal
}

Copy-Item "$PowerEditorSource" -Destination "$PowerEditorLocal\bin" -Recurse -Force
New-Item "$PowerEditorLocal\bin\doLocalConf.xml" > $nul
New-Item "$PowerEditorLocal\bin\userDefineLangs" -ItemType Directory -ea 0 > $nul
python doUnitTests.py $PowerEditorLocal\bin

cd ..
