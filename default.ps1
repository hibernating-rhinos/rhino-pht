properties { 
  $base_dir  = resolve-path .
  $lib_dir = "$base_dir\SharedLibs"
  $build_dir = "$base_dir\build" 
  $buildartifacts_dir = "$build_dir\" 
  $packageinfo_dir = "$base_dir\packaging"
  $sln_file = "$base_dir\Rhino.PersistentHashTable.sln" 
  $version = "1.7.0.0"
  $humanReadableversion = "1.7"
  $tools_dir = "$base_dir\Tools"
  $release_dir = "$base_dir\Release"
  $uploadCategory = "Rhino-PHT"
  $uploadScript = "C:\Builds\Upload\PublishBuild.build"
} 

$framework = "4.0"

include .\psake_ext.ps1
	
task default -depends Package

task Clean { 
  remove-item -force -recurse $buildartifacts_dir -ErrorAction SilentlyContinue 
  remove-item -force -recurse $release_dir -ErrorAction SilentlyContinue 
} 

task Init -depends Clean { 
	Generate-Assembly-Info `
		-file "$base_dir\Rhino.PersistentHashTable\Properties\AssemblyInfo.cs" `
		-title "Rhino PersistentHashTable $version" `
		-description "Persistent Hash Table" `
		-company "Hibernating Rhinos" `
		-product "Rhino PHT $version" `
		-version $version `
		-copyright "Hibernating Rhinos & Ayende Rahien 2004 - 2009"
		
	Generate-Assembly-Info `
		-file "$base_dir\Rhino.PersistentHashTable.Tests\Properties\AssemblyInfo.cs" `
		-title "Rhino PersistentHashTable $version" `
		-description "Persistent Hash Table" `
		-company "Hibernating Rhinos" `
		-product "Rhino PHT $version" `
		-version $version `
		-copyright "Hibernating Rhinos & Ayende Rahien 2004 - 2009"
        
    Generate-Assembly-Info `
		-file "$base_dir\Rhino.PersistentHashTable.Util\Properties\AssemblyInfo.cs" `
		-title "Rhino PersistentHashTable Util $version" `
		-description "Persistent Hash Table Utils" `
		-company "Hibernating Rhinos" `
		-product "Rhino PHT Util $version" `
		-version $version `
		-copyright "Hibernating Rhinos & Ayende Rahien 2004 - 2009"
		
	new-item $release_dir -itemType directory 
	new-item $buildartifacts_dir -itemType directory 
} 

task Compile -depends Init { 
  msbuild $sln_file /p:"OutDir=$buildartifacts_dir"
} 

task Test -depends Compile {
  $old = pwd
  cd $build_dir
  & $tools_dir\xUnit\xunit.console.clr4.exe "$build_dir\Rhino.PersistentHashTable.Tests.dll"
  cd $old		
}


task Release -depends Test {
  cd $build_dir
	& $tools_dir\7za.exe a $release_dir\Rhino.PersistentHashTable.zip `
    	*\Esent.Interop.dll `
    	*\Esent.Interop.xml `
    	*\Esent.Interop.pdb `
    	*\Rhino.PersistentHashTable.dll `
    	*\Rhino.PersistentHashTable.xml `
    	*\Rhino.PersistentHashTable.pdb `
		license.txt `
		acknowledgements.txt
	if ($lastExitCode -ne 0) {
        throw "Error: Failed to execute ZIP command"
    }
}

task Package -depends Release {
  & $tools_dir\NuGet.exe pack $packageinfo_dir\rhino.pht.nuspec -o $release_dir -Version $version -Symbols -BasePath $build_dir
}
