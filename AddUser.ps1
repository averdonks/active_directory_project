"`n"
Write-Host "Welcome to the AddUser script!"
"`n"
"Please fill out the following information to create a new user." 
"`n"

# Initialize variables

$firstName  = ""
$lastName   = ""
$username   = ""
$fullName   = ""
$password   = ""

$i = 0
$parameter  = ""
$promptText = ""

# Iterate and assign values to the variables for the firstname, lastname, and username

while ($i -le 2)
{
    if ($i -eq 0)
    {
        $promptText = "Enter the user's first name"
    }
    elseif ($i -eq 1)
    {
        $promptText = "Enter the user's last name"
    }
    elseif ($i -eq 2)
    {
        $promptText = "Enter the user's username"
    }

    Do
    {
        $parameter = Read-Host -Prompt $promptText
    } while ($parameter -eq "")

    if ($i -eq 0)
    {
        $firstName = $parameter
    }
    elseif ($i -eq 1)
    {
        $lastName = $parameter
    }
    elseif ($i -eq 2)
    {
        $username = $parameter
    }

    $i++
}

# Check if the User already exists in Active Directory

if (Get-ADUser -Filter {SamAccountName -eq $username})
{
    Write-Warning "User account $username already exists in Active Directory."
    exit
}
else
{
   Write-Host "Which Department does the user belong to?"

   # Assign values to the department and password variables

   Do 
   {
        $department = Read-Host -Prompt "[1] IT [2] HR"
        if ($department -notmatch '^[1-2]+$') 
        {   
            Write-Warning "Please enter a number: 1 or 2."
        }
   } while ($department  -notmatch '^[1-2]+$')
   $password = Read-Host -Prompt "Enter the user's password"

   # Change value of the department variable to match the chosen OU

   if ($department -eq 1) 
   {
        $department = "IT"
   }
   elseif ($department -eq 2)
   {
        $department = "HR"
   }
}

# Create the user based on the previously assigned variables

New-ADUser `
-Name "$firstName $lastName" `
-GivenName $firstName `
-Surname $lastName `
-SamAccountName $username `
-UserPrincipalName $username `
-AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
-Path "OU=$department,DC=homelab,DC=test" `
-Enabled $true

Get-ADUser -Identity $username

Write-Host "User $username successfully created!"