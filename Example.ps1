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
       "Index" = 0
       };
    "last" = @{
       "Label" = "Last Name:";
       "Required" = $true;
       "Index" = 1
       };
    "enabled" = @{
       "Label" = "User Enabled:";
       "InputType" = "CheckBox";       
       "Index" = 2
       };
    "userDirectory" = @{
       "Label" = "User Directory:";
       "InputType" = "DirChooser";
       "Required" = $true;
       "Index" = 3
       };
    "notes" = @{
       "Label" = "Notes:";
       "InputType" = "TextArea";
       "Index" = 4
       };
};

# Call Gather Inputs Form
$formResults = GatherInputsForm -title "Project Details" -inputs $inputs -labelWidth 150

# Do work with results (just displaying in simple demo)
$formResults