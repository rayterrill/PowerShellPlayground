<#
Outputs SSIS package details by shredding the package's xml for documentation purposes.

For now, this is rudimentary:
   *Finds executables and any components contained within
   *Finds table info if using the OpenRowset property

*** Requires that the package not be encrypted. ***

EXAMPLE:
Parse a package to output details:
./Get-SSISXMLDetails -ssisPackage "c:\Visual Studio 2012\Projects\Integration Services Project5\Integration Services Project5\Package.dtsx"
#>

[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True)][string]$ssisPackage
)

[xml]$xmlDocument = Get-Content $ssisPackage

#go throught the executables (data flow component, etc)
$executables = $xmlDocument.Executable.Executables
foreach ($e in $executables) {
   $objectName = $e.Executable.ObjectName

   $objectData = $e.Executable.ObjectData
   $components = $objectData.pipeline.Components

   foreach ($c in $components.component) {
      $componentName = $c.Name
      $connection = $c.Connections.connection.connectionManagerID
      $componentClassID = $c.componentClassID

      $type = switch ($componentClassID) {
         '{165A526D-D5DE-47FF-96A6-F8274C19826B}' {'OLE DB Source'}
         '{4ADA7EAA-136C-4215-8098-D7A7C27FC0D1}' {'OLE DB Destination'}
         default {"Unknown"}
      }
      
      $table = ($c.properties.property | where-object {$_.Name -eq 'OpenRowset'}).'#text'

      Write-Host "Component: $($c.Name)"
      Write-Host "Connection Info: $($connection)"
      Write-Host "Connection Type: $($type)"
      Write-Host "Table Used: $($table)"
      Write-Host
   }
}
