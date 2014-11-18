param (
    [string]$first = "Cher",
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
       # Only person I know without a last name is cher, so lastname is required if first name is not equal to cher
       "RequiredIf" = @{ "OtherProperty" = "first"; "Condition" = "NotEqualTo"; "Value" = "Cher" };
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
       "RequiredIf" = @{ "OtherProperty" = "enabled"; "Condition" = "EqualTo"; "Value" = $true };
       "Index" = 3;
       "DefaultValue" = $userDirectory;
       };
    "notes" = @{
       "Label" = "Notes:";
       "InputType" = "TextArea";
       "Required" = $true;
       "Index" = 4;
       "DefaultValue" = $notes;
       };
};

# Determine if anything set by command line arguments, if so autosubmit
$autoSubmit = $false;
if ([bool]$first -or
    [bool]$last -or
    [bool]$enabled -or
    [bool]$userDirectory -or
    [bool]$notes) {
        $autoSubmit = $true
}

# Call Gather Inputs Form
$formResults = GatherInputsForm -title "Project Details" -inputs $inputs -labelWidth 150 -AutoSubmit $autoSubmit

# Do work with results (just displaying in simple demo)
$formResults | Out-GridView