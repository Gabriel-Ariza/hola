param(
    [Parameter(Mandatory=$true)] [string]$repo,
    [string]$username = "Gabriel-Ariza",
    [string]$token = "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"
)

# URL API GitHub
$uri = "https://api.github.com/repos/$username/$repo"


# obtengo la informacion del repo con la URL
try {
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers @{Authorization="token $token"}
} catch {
    Write-Host "`n`n-----> No existe un repositorio llamado '$repo'...`n`n`n"
    exit
}

# parseo fechas del repo
$createdDate = [DateTime]::Parse($response.created_at)
$formattedCreatedDate = $createdDate.ToString("yyyy-MM-dd HH:mm:ss")
$updatedDate = [DateTime]::Parse($response.updated_at)
$formattedUpdatedDate = $updatedDate.ToString("yyyy-MM-dd HH:mm:ss")


Write-Host "`n---------------------------------------------------"
Write-Host "      --->  Informacion del repositorio  <---      "
Write-Host "---------------------------------------------------`n"
Write-Host "    Nombre: $($response.name)"
Write-Host "    Descripcion: $($response.description)"
Write-Host "    Fecha de creacion: $($formattedCreatedDate)"
Write-Host "    Ultima actualizacion: $($formattedUpdatedDate)"
Write-Host "    URL: $($response.html_url)`n"
Write-Host "---------------------------------------------------`n`n`n"


$line = "-" * 48
$oauth = Read-Host "password para borrar el repositorio:`n  ----->" -AsSecureString
$importfilePath = "./zanahorias.txt"
$storedlibrary = Get-Content $importfilePath


if ($null -ne $oauth) {
    $CharEnIgma = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($oauth)
    $BSTR = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($CharEnIgma)
} else {
    Write-Host "`n`n-----> No se proporciono una contraseña.`n`n"
    exit
}

# si la contraseña es valida entra
if ($null -ne $BSTR -and $BSTR -eq $storedlibrary) {

    # obtengo fecha creacion del repo
    $repoCreationDate = [DateTime]::Parse($response.created_at)
    $currentDate = Get-Date
    $daysDifference = ($currentDate - $repoCreationDate).Days


    $hasCommits = $true


    # obtengo commits del repo
    try {
        $res = Invoke-WebRequest -Uri "https://api.github.com/repos/Gabriel-Ariza/$repo/commits" -Method Get -Headers @{
            "Authorization" = "token $token"
        }
    
        if ($res.StatusCode -eq 200) {
            $response_commit = $res.Content | ConvertFrom-Json
            $lastCommitDate = [DateTime]::Parse($response_commit[0].commit.author.date)
        } else {
            Write-Host "`n`n  El repositorio no tiene commits`n`n"
            $hasCommits = $false
        }
    
    } catch {
        if ($_.Exception.Response.StatusCode -eq 409) {
            Write-Host "`n  -----> El repositorio no tiene commits"
            $hasCommits = $false
        } else {
            Write-Host "`n`n-----> Ocurrio un error al obtener los commits del repositorio`n`n"
            Write-Host "Detalles del error: $($_.Exception.Message)"
            exit
        }
    }


    # funcion que intenta eliminar el repo
    function Delete-Repo {
        try {
            $response = Invoke-RestMethod -Uri $uri -Method DELETE -Headers @{Authorization="token $token"}
            Write-Host "`n`n$line`n`tRepositorio eliminado con exito.`n$line`n"
            Write-Host "  repositorio: $($repo)`n`n`n"
        } catch {
            Write-Host "`n`n-----> Ocurrio un error al intentar eliminar el repositorio...`n"
            Write-Host "  repositorio: $($repo)`n`n`n"
        }
    }


    # si tiene commits el repo valido
    if ($hasCommits) {
        if ($daysDifference -gt 8) {
            Write-Host "`n`n-----> El repositorio tiene más de 8 días de antigüedad"
            Write-Host "`n----->  $($repo) No se puede eliminar ...`n`n`n`n"
            exit

        } elseif (($currentDate - $lastCommitDate).TotalDays -lt 2) {
            Write-Host "`n`n-----> El repositorio fue actualizado hace menos de 2 dias"
            Write-Host "`n----->  $($repo) No se puede eliminar ...`n`n`n`n"
            exit

        } else {
            Delete-Repo
        }

    } else {
        if ($daysDifference -gt 4) {
            Write-Host "`n`n-----> El repositorio tiene más de 4 días de antigüedad, no se puede eliminar ...`n`n"
            exit

        } else {
            Delete-Repo
        }
    }



    # si la contraseña es incorrecta
} else {
    Write-Host "`n`n`contrasena incorrecta`n`nError al eliminar el repositorio $($repo).`n`n`n`n"
}