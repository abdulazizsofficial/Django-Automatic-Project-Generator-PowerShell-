$ErrorActionPreference = "Stop"

function Fix-Name($name, $type) {
    if ($name -match " ") {
        Write-Host ""
        Write-Host "WARNING: $type name contains spaces!"
        Write-Host "Spaces are NOT allowed. Converting to '_' ..."
        Write-Host ""
    }
    return $name -replace " ", "_"
}

try {
    Write-Host "====================================="
    Write-Host " Django Automatic Project Creator"
    Write-Host "====================================="
    Write-Host ""

    # INPUT
    $ProjectName = Read-Host "Enter Django Project Name"
    $AppName = Read-Host "Enter Django App Name"

    # FIX NAMES
    $ProjectName = Fix-Name $ProjectName "Project"
    $AppName = Fix-Name $AppName "App"

    # 1. VENV
    Write-Host "`n[1/9] Creating virtual environment..."
    python -m venv env

    # 2. ACTIVATE
    Write-Host "[2/9] Activating virtual environment..."
    & ".\env\Scripts\Activate.ps1"

    # 3. PIP UPGRADE
    Write-Host "[3/9] Upgrading pip..."
    python -m pip install --upgrade pip

    # 4. DJANGO INSTALL
    Write-Host "[4/9] Installing Django..."
    pip install django

    # 5. PROJECT CREATE
    Write-Host "[5/9] Creating Django project..."
    django-admin startproject $ProjectName

    Set-Location $ProjectName

    # 6. APP CREATE
    Write-Host "[6/9] Creating Django app..."
    python manage.py startapp $AppName

    # 7. ADD APP TO SETTINGS
    Write-Host "[7/9] Adding app to INSTALLED_APPS..."

    $SettingsPath = ".\$ProjectName\settings.py"
    $Content = Get-Content $SettingsPath -Raw

    $Content = $Content -replace "INSTALLED_APPS = \[", "INSTALLED_APPS = [`n    '$AppName',"

    Set-Content $SettingsPath $Content

    # 8. MIGRATIONS
    Write-Host "[8/9] Running migrations..."
    python manage.py makemigrations
    python manage.py migrate

    # 9. SUPERUSER (FIXED METHOD)
    Write-Host "[9/9] Creating superuser..."

    python manage.py shell -c "
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    User.objects.create_superuser('admin', 'zinnat790@gmail.com', '1')
    print('Superuser created successfully')
else:
    print('Superuser already exists')
"

    # FINAL OUTPUT
    Write-Host ""
    Write-Host "====================================="
    Write-Host " SETUP COMPLETED SUCCESSFULLY "
    Write-Host "====================================="
    Write-Host "Project Name : $ProjectName"
    Write-Host "App Name     : $AppName"
    Write-Host "Admin User   : admin"
    Write-Host "Admin Email  : zinnat790@gmail.com"
    Write-Host "Password     : 1"
    Write-Host "====================================="
}
catch {
    Write-Host ""
    Write-Host "ERROR OCCURRED:"
    Write-Host $_.Exception.Message
}

# STOP WINDOW FROM CLOSING
Read-Host "Press Enter to exit"