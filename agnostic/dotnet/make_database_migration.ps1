<#
.SYNOPSIS
    Creates a new Entity Framework Core migration

.DESCRIPTION
    This script simplifies the process of creating EF Core migrations by providing
    default paths and interactive prompts. It uses the Infrastructure project as
    the target and the Api project as the startup project.

.PARAMETER MigrationName
    The name of the migration to create. If not provided, the script will prompt for it.

.PARAMETER ProjectPath
    Path to the Infrastructure project. Default: ..\src\Hosting\Infrastructure

.PARAMETER StartupProjectPath
    Path to the startup project (Api). Default: ..\src\Api\

.PARAMETER OutputDir
    Output directory for migrations within the project. Default: Database\Migrations\

.EXAMPLE
    .\make_database_migration.ps1
    Runs interactively, prompting for migration name

.EXAMPLE
    .\make_database_migration.ps1 -MigrationName "AddUserEntity"
    Creates a migration with the specified name using default paths

.NOTES
    Requires .NET CLI and Entity Framework Core tools to be installed.
    Run 'dotnet tool install --global dotnet-ef' if EF tools are not installed.
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$MigrationName,
    
    [Parameter(Mandatory = $false)]
    [string]$ProjectPath = "..\src\Hosting\Infrastructure",
    
    [Parameter(Mandatory = $false)]
    [string]$StartupProjectPath = "..\src\Api\",
    
    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "Database\Migrations\"
)

function Show-Header {
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "   EF Core Migrations Helper                    " -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-ProjectPaths {
    param(
        [string]$InfrastructurePath,
        [string]$ApiPath
    )
    
    $infraExists = Test-Path $InfrastructurePath
    $apiExists = Test-Path $ApiPath
    
    if (-not $infraExists) {
        Write-Warning "Infrastructure project path not found: $InfrastructurePath"
    }
    
    if (-not $apiExists) {
        Write-Warning "Api project path not found: $ApiPath"
    }
    
    return $infraExists -and $apiExists
}

function Get-MigrationName {
    do {
        $name = Read-Host "Enter migration name (e.g., 'AddUserEntity', 'UpdateProductSchema')"
        if ([string]::IsNullOrWhiteSpace($name)) {
            Write-Host "Migration name cannot be empty. Please try again." -ForegroundColor Yellow
        }
    } while ([string]::IsNullOrWhiteSpace($name))
    
    return $name.Trim()
}

function Show-Configuration {
    param(
        [string]$Name,
        [string]$Project,
        [string]$Startup,
        [string]$Output
    )
    
    Write-Host "Current Configuration:" -ForegroundColor Green
    Write-Host "  Migration Name:    $Name" -ForegroundColor White
    Write-Host "  Project Path:      $Project" -ForegroundColor White
    Write-Host "  Startup Project:   $Startup" -ForegroundColor White
    Write-Host "  Output Directory:  $Output" -ForegroundColor White
    Write-Host ""
}

try {
    Clear-Host
    Show-Header
    
    if ([string]::IsNullOrWhiteSpace($MigrationName)) {
        Write-Host "No migration name provided. Let's create one interactively." -ForegroundColor Yellow
        Write-Host ""
        $MigrationName = Get-MigrationName
    }
    
    Show-Configuration -Name $MigrationName -Project $ProjectPath -Startup $StartupProjectPath -Output $OutputDir
    
    Write-Host "Validating project paths..." -ForegroundColor Yellow
    if (-not (Test-ProjectPaths -InfrastructurePath $ProjectPath -ApiPath $StartupProjectPath)) {
        Write-Host "Path validation failed. Please check the project paths and try again." -ForegroundColor Red
        exit 1
    }
    Write-Host "✓ Project paths validated successfully" -ForegroundColor Green
    Write-Host ""
    
    $confirmation = Read-Host "Do you want to create the migration? (Y/n)"
    if ($confirmation -eq 'n' -or $confirmation -eq 'N') {
        Write-Host "Migration creation cancelled." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "Creating migration '$MigrationName'..." -ForegroundColor Yellow
    Write-Host "Command: dotnet ef migrations add $MigrationName --project $ProjectPath --startup-project $StartupProjectPath --output-dir $OutputDir" -ForegroundColor Gray
    Write-Host ""
    
    dotnet ef migrations add $MigrationName --project $ProjectPath --startup-project $StartupProjectPath --output-dir $OutputDir
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ Migration '$MigrationName' created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next steps:" -ForegroundColor Cyan
        Write-Host "  1. Review the generated migration files in: $ProjectPath\$OutputDir" -ForegroundColor White
        Write-Host "  2. Apply the migration with: dotnet ef database update --project $ProjectPath --startup-project $StartupProjectPath" -ForegroundColor White
        Write-Host "  3. Or apply specific migration: dotnet ef database update $MigrationName --project $ProjectPath --startup-project $StartupProjectPath" -ForegroundColor White
    } else {
        Write-Host ""
        Write-Host "✗ Migration creation failed. Please check the error messages above." -ForegroundColor Red
        exit 1
    }
    
} catch {
    Write-Host ""
    Write-Host "✗ An error occurred: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
