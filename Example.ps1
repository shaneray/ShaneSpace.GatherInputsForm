param (
    [string]$first = "Shane",
    [string]$last = "",
    [bool]$enabled = $false,
    [string]$userDirectory = "",
    [string]$notes = ""
 )

# Get Script Directory Path
$scriptpath = $MyInvocation.MyCommand.Path
$dir = Split-Path $scriptpath

# Include Input form method
. "$dir\GatherInputsForm.ps1"

# Define Inputs
$inputs = @{ 
    "first" = @{ 
       "Label" = "First Name:";
       "Required" = $true;
       "Index" = 0;
       "DefaultValue" = $first;
       };
    "last" = @{
       "Label" = "Last Name:";
       "Required" = $true;
       "Index" = 1;
       "DefaultValue" = $last;
       };
    "enabled" = @{
       "Label" = "User Enabled:";
       "InputType" = "CheckBox";       
       "Index" = 2;
       "DefaultValue" = $enabled;
       };
    "userDirectory" = @{
       "Label" = "User Directory:";
       "InputType" = "DirChooser";
       "Required" = $true;
       "Index" = 3;
       "DefaultValue" = $userDirectory;
       };
    "notes" = @{
       "Label" = "Notes:";
       "InputType" = "TextArea";
       "Index" = 4;
       "DefaultValue" = $notes;
       };
};

# Determine if anything set by command line arguments, if so autosubmit
$autoSubmit = $false;
if ($first -ne "" -or $first -ne $false) { $autoSubmit = $true }
if ($last -ne "" -or $last -ne $false) { $autoSubmit = $true }
if ($enabled -ne "" -or $enabled -ne $false) { $autoSubmit = $true }
if ($userDirectory -ne "" -or $userDirectory -ne $false) { $autoSubmit = $true }
if ($notes -ne "" -or $notes -ne $false) { $autoSubmit = $true }

# Call Gather Inputs Form
$formResults = GatherInputsForm -title "Project Details" -inputs $inputs -labelWidth 150 -AutoSubmit $autoSubmit

# Do work with results (just displaying in simple demo)
$formResults