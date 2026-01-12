$dotnetversion = where dotnet | dotnet --version

Write-Output "Run Compile & Test"
Write-Output "---------------"
dotnet restore MigrationTools.sln
dotnet build MigrationTools.sln /p:Version=$($versionInfo.AssemblySemVer) /p:FileVersion=$($versionInfo.AssemblySemVer) /p:InformationalVersion=$($versionInfo.InformationalVersion)

dotnet test --collect "Code coverage" --no-build --filter "(TestCategory=L0|TestCategory=L1)" --logger trx --results-directory .\output\testresults
dotnet test --collect "Code coverage" --no-build --filter "(TestCategory=L2|TestCategory=L3)" --logger trx --results-directory .\output\testresults
dotnet test --collect "Code coverage" --no-build --filter "(TestCategory!=L0&TestCategory!=L1&TestCategory!=L2&TestCategory!=L3)" --logger trx --results-directory .\output\testresults

Write-Output "---------------"
