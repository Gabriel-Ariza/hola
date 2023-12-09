param(
    [Parameter(Mandatory=$true)] [string]$repo,
    [string]$username = "Gabriel-Ariza",
    [string]$token = "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"
)


try {
    $uri = "https://api.github.com/user/repos"
    $response = Invoke-RestMethod -Uri $uri -Method POST -Body (ConvertTo-Json -InputObject @{name=$repo}) -Headers @{Authorization="token $token"}
    
    $line = "-" * 45
    Write-Host "`n`n$line`n`tRepositorio creado con exito.`n$line`n"
    Write-Host "URL: $($response.html_url)`nFecha de creacion: $($response.created_at)`n`n"

    Write-Host "---------------------------------------------------"
    Write-Host "git add .`ngit commit -m 'subida de archivos'"
    Write-Host "git remote add origin https://github.com/$username/$repo.git"
    Write-Host "git branch -M main"
    Write-Host "git push -u origin main"
    Write-Host "---------------------------------------------------`n`n`n"


} catch {
    Write-Host "`n`n-----> Ocurrio un error al intentar crear el repositorio...`n"
    Write-Host "Detalles del error: $($_.Exception.Message)`n"
}