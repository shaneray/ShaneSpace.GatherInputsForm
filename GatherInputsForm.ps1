function GatherInputsForm ($title, $inputs, $autoSubmit = $false, $labelWidth = 150) {
    # Wrap everything but final output to avoid unwanted output
    $null = .{
        # Put input objects in order
        $inputs = $inputs.GetEnumerator() | sort-object { $_.value.index };

        # Load Assembly for creating form & buttos
        [void][System.Reflection.Assembly]::LoadWithPartialName(“System.Windows.Forms”)
        [void][System.Reflection.Assembly]::LoadWithPartialName(“Microsoft.VisualBasic”)
        [void][Windows.Forms.Application]::EnableVisualStyles()

        # Define the form size & placement
        $formOutput = @{};
        
        $form = New-Object “System.Windows.Forms.Form”;
        $form.Width = $labelWidth + 250;
        $form.Height = ($inputs.Count + 1) * 50;
        $form.Text = $title;
        $Form.MinimizeBox = $False;
        $Form.MaximizeBox = $False;
        $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen;
        
        $counter = 0;
        $top = 15;
        $textLabel = @{};
        $textBox = @{};
        $folderBrowserEvent = @{};

        # build form content
        foreach ($key in $inputs) {
            # Add controls
            if ($key.Value.InputType -eq "CheckBox") {
                $textBox[$key.Name] = New-Object “System.Windows.Forms.CheckBox”;
                if ($key.Value.DefaultValue -eq $true) {
                    $textBox[$key.Name].CheckState = "Checked";
                }
            }
            elseif ($key.Value.InputType -eq "DirChooser") {
                # Add textbox with tag
                $textBox[$key.Name] = New-Object “System.Windows.Forms.TextBox”;
                $textBox[$key.Name].Tag = $key.Name;
                $textBox[$key.Name].Text = $key.Value.DefaultValue;
                # open folder browser and set output to the textbox with value
                $folderBrowserEvent = [System.EventHandler] {
                    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog;
                    [void]$FolderBrowser.ShowDialog();
                    $textBox[$this.Tag].Text = $FolderBrowser.SelectedPath;
                };

                # define browse button
                $browseButton = New-Object “System.Windows.Forms.Button”;
                $browseButton.Text = "...";
                $browseButton.Top = $top;
                $browseButton.Width = 25;
                $browseButton.Height = 20;
                $browseButton.Left = $labelWidth + 15 + 175;
                $browseButton.Tag = $key.Name;
                [void]$browseButton.Add_Click($folderBrowserEvent);
                $form.Controls.Add($browseButton);
            }
            elseif ($key.Value.InputType -eq "TextArea") {
                $textBox[$key.Name] = New-Object “System.Windows.Forms.TextBox”;
                $textBox[$key.Name].Text = $key.Value.DefaultValue;
            }
            else {
                $textBox[$key.Name] = New-Object “System.Windows.Forms.TextBox”;
                $textBox[$key.Name].Text = $key.Value.DefaultValue;                      
            }

            $textBox[$key.Name].Left = $labelWidth + 15;
            $textBox[$key.Name].Top = $top;

            if ($key.Value.InputType -eq "DirChooser") {
                $textBox[$key.Name].Width = 175;
            }
            else {
                $textBox[$key.Name].Width = 200;
            }

            [void]$form.Controls.Add($textBox[$key.Name]);
            
            #Add labels
            $textLabel[$key.Name] = New-Object “System.Windows.Forms.Label”;
            $textLabel[$key.Name].Left = 15;
            $textLabel[$key.Name].Top = $top;
            $textLabel[$key.Name].Width = $labelWidth;
            $textLabel[$key.Name].Text = $key.Value.Label;
            [void]$form.Controls.Add($textLabel[$key.Name]);

            if ($key.Value.InputType -eq "TextArea") {
                $top = $top + 70;
                $textBox[$key.Name].MultiLine = $true;
                $textBox[$key.Name].Height = 60;
            }
            else {
                $top = $top + 30;
            }

            $counter++;
        }

        $textBox["formCanceled"] = New-Object "System.Windows.Forms.Textbox";
        $textBox["formCanceled"].Text = "True";
        $textBox["formCanceled"].Visible = $true;

        # define OK button
        $button = New-Object “System.Windows.Forms.Button”;
        $button.Left = 15;
        $button.Top = $top;
        $button.Width = 100;
        $button.Text = “Ok”;

        # define Cancel button
        $buttonCancel = New-Object “System.Windows.Forms.Button”;
        $buttonCancel.Left = 130;
        $buttonCancel.Top = $top;
        $buttonCancel.Width = 100;
        $buttonCancel.Text = “Cancel”;

        $top = $top + 85;
        $form.Height = $top;

        # Ok Event
        $eventHandler = [System.EventHandler]{
            $passedValidation = $true;
            foreach ($key in $inputs) {
                # Cant run validation on a checkbox as value will always be true or false
                if ($textBox[$key.Name].GetType().Name -eq "CheckBox") {
                    continue;
                }

                # Make background default color (white)
                $textBox[$key.Name].BackColor = "White";

                # if Required is set and text is empty highlight
                if (($key.Value.Required -eq $true) -and ($textBox[$key.Name].Text -eq "")) {
                    $textBox[$key.Name].BackColor = "Yellow";
                    $passedValidation = $false;
                }

                # if Required if is set, check
                if ($key.Value.RequiredIf -ne $null) {

                    # get value of "Other Property"
                    $currentValue = $textBox[$key.Value.RequiredIf.OtherProperty].Text;

                    # if other property is  checkbox set value to true or false
                    if ($textBox[$key.Value.RequiredIf.OtherProperty].GetType().Name -eq "CheckBox") {
                        if ($textBox[$key.Value.RequiredIf.OtherProperty].CheckState -eq "Checked") {
                            $currentValue = $true;
                        }
                        else {
                            $currentValue = $false;
                        }
                    }
                    
                    # Check required if conditions
                    if (($key.Value.RequiredIf.Condition -eq "EqualTo") -and ($currentValue -eq $key.Value.RequiredIf.Value) -and ($textBox[$key.Name].Text -eq "")) {
                        $textBox[$key.Name].BackColor = "Yellow";
                        $passedValidation = $false;
                    }
                    if (($key.Value.RequiredIf.Condition -eq "NotEqualTo") -and ($currentValue -ne $key.Value.RequiredIf.Value)-and ($textBox[$key.Name].Text -eq "")) {
                        $textBox[$key.Name].BackColor = "Yellow";
                        $passedValidation = $false;
                    }
                }
            }

            # Passed validation
            if ($passedValidation -eq $true) {
                # Form was not canceled
                $textBox["formCanceled"].Text = "False";

                # fill out the output object
                foreach ($key in $inputs) {
                    if ($key.Value.InputType -eq "CheckBox") {
                        if ($textBox[$key.Name].CheckState -eq "Checked") {
                            [void]$formOutput.Add($key.Name, $true);
                        }
                        else {
                            [void]$formOutput.Add($key.Name, $false);                            
                        }
                    }
                    else {
                        [void]$formOutput.Add($key.Name, $textBox[$key.Name].Text);    
                    }
                }

                # Close the form
                [void]$form.Close();
            }
            else {
                [void][System.Windows.Forms.MessageBox]::Show("There are required fields that do not have a value.  Required fields have been highlighted, please enter a value and try again.");        
            }
        };
        [void]$button.Add_Click($eventHandler);
        
        # Cancel Event
        $CancelEventHandler = [System.EventHandler]{
            $textBox["formCanceled"].Text = "True";
            [void]$form.Close();
        };
        [void]$buttonCancel.Add_Click($CancelEventHandler);
        
        # Form Open Event
        $formOpenEventHandler = [System.EventHandler] {
            if ($autoSubmit -eq $true) {
                $button.PerformClick();
            }    
        };

        # Add controls to all the above objects defined
        $form.Controls.Add($button);
        $form.Controls.Add($buttonCancel);
        $form.Controls.Add($cancelBox);
        $form.Add_Shown($formOpenEventHandler);
        [void]$form.ShowDialog();
    }

    if ($textBox["formCanceled"].Text -eq "True") {
        Write-host "User canceled out of input dialog... Script aborting.";
        Exit
    }

    #return values
    $formOutput
}