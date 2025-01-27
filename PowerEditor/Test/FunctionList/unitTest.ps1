# This script does 1 unit-test on given relative dir path and on given language.
# Here's its syntax:
# .\unit-test.ps1 RELATIVE_PATH LANG
# It return 0 if result is OK
#          -1 if result is KO
#          -2 if exception
#           1 if unitTest file not found


$testRoot = ".\"

$dirName=$args[0]
$langName=$args[1]

Try {
	if ((Get-Item $testRoot$dirName) -is [System.IO.DirectoryInfo])
	{
		if (-Not (Test-Path $testRoot$dirName\unitTest))
		{
			return 1
		}
		if ($langName.StartsWith("udl-"))
		{
			$langName = $langName.Replace("udl-", "")
			..\..\bin\Notepad+-.exe -export=functionList -udl="`"$langName"`" $testRoot$dirName\unitTest | Out-Null
		}
		else
		{
			..\..\bin\Notepad+-.exe -export=functionList -l"$langName" $testRoot$dirName\unitTest | Out-Null
		}

		$expectedRes = Get-Content $testRoot$dirName\unitTest.expected.result
		$generatedRes = Get-Content $testRoot$dirName\unitTest.result.json
		
		# Some parser results contain CRLF or LF (\r\n or \n) dependent of file EOL format
		# In order to make tests pass in any environment, all the CRLF turning into LF (if any) in both strings 
		$expectedRes = $expectedRes.replace('\r\n','\n')
		$generatedRes = $generatedRes.replace('\r\n','\n')
		
		if ($generatedRes -eq $expectedRes)
		{
		   Remove-Item $testRoot$dirName\unitTest.result.json
		   return 0
		}
		else
		{
			$expectedRes
			"`nvs`n"
			$generatedRes
			return -1
		}	
	}
}
Catch
{
	return -2
}
