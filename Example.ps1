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

# Call Gather Inputs Form
$formResults = GatherInputsForm -title "Project Details" -inputs $inputs -labelWidth 150

# Do work with results (just displaying in simple demo)
$formResults