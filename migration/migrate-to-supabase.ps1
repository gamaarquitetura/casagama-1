<#
Casa Gama — migração Firebase → Supabase
Carrega migration/casagama_categorias.json e migration/casagama_produtos.json
(já extraídos do Firestore e transformados) para as tabelas do Supabase.

Requer, como variáveis de ambiente:
  SUPABASE_URL               ex: https://xxxxx.supabase.co
  SUPABASE_SERVICE_ROLE_KEY  a service_role key do projeto (NUNCA a publishable/anon)
                             — só ela ignora o RLS para essa carga em massa única.
                             Nunca commitar nem deixar salva depois de usar.

Rodar depois de aplicar migration/001_add_codigo_column.sql no Supabase.

Uso:
  $env:SUPABASE_URL = "https://xxxxx.supabase.co"
  $env:SUPABASE_SERVICE_ROLE_KEY = "eyJ..."
  .\migrate-to-supabase.ps1
#>

$ErrorActionPreference = "Stop"

$SupabaseUrl = $env:SUPABASE_URL
$ServiceKey  = $env:SUPABASE_SERVICE_ROLE_KEY

if (-not $SupabaseUrl -or -not $ServiceKey) {
  Write-Error "Defina SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY como variáveis de ambiente antes de rodar este script."
  exit 1
}

$headers = @{
  "apikey"        = $ServiceKey
  "Authorization" = "Bearer $ServiceKey"
  "Content-Type"  = "application/json"
  "Prefer"        = "resolution=merge-duplicates,return=representation"
}

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$categorias = Get-Content (Join-Path $scriptDir "casagama_categorias.json") -Raw | ConvertFrom-Json
$produtos   = Get-Content (Join-Path $scriptDir "casagama_produtos.json")   -Raw | ConvertFrom-Json

Write-Output "Enviando $($categorias.Count) categorias..."
$catBody = $categorias | ConvertTo-Json -Depth 4
$catResp = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/casagama_categorias?on_conflict=slug" -Method Post -Headers $headers -Body $catBody
Write-Output "Categorias OK: $($catResp.Count) linhas."

Write-Output "Enviando $($produtos.Count) produtos..."
$prodBody = $produtos | ConvertTo-Json -Depth 4
$prodResp = Invoke-RestMethod -Uri "$SupabaseUrl/rest/v1/casagama_produtos?on_conflict=codigo" -Method Post -Headers $headers -Body $prodBody
Write-Output "Produtos OK: $($prodResp.Count) linhas."

Write-Output "Migração concluída."
