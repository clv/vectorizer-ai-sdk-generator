[CmdletBinding()]
param(
    [switch]$Deep,
    [switch]$KeepBuildArtifacts
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path

$GeneratorVersion = "7.6.0"
$JarName = "openapi-generator-cli-$GeneratorVersion.jar"
$Jar = Join-Path $Root $JarName
$JarUrl = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$GeneratorVersion/$JarName"

if (!(Test-Path -LiteralPath $Jar)) {
    Write-Host "Downloading OpenAPI Generator CLI $GeneratorVersion..."
    Invoke-WebRequest -Uri $JarUrl -OutFile $Jar
}

function Assert-FileContains($Path, $Pattern, $Description) {
    if (!(Test-Path -LiteralPath $Path)) {
        throw "Missing $Description at $Path"
    }
    if (!(Select-String -LiteralPath $Path -Pattern $Pattern -SimpleMatch -Quiet)) {
        throw "Could not find '$Pattern' in $Description ($Path)"
    }
}

function Remove-GeneratedArtifact($Path) {
    if (!(Test-Path -LiteralPath $Path)) {
        return
    }
    $RootFull = [System.IO.Path]::GetFullPath($Root)
    $PathFull = [System.IO.Path]::GetFullPath($Path)
    if (!$PathFull.StartsWith($RootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to remove build artifact outside SDK root: $PathFull"
    }
    Remove-Item -LiteralPath $PathFull -Recurse -Force
}

Write-Host "Checking OpenAPI spec"
& java -jar $Jar validate -i (Join-Path $Root "openapi.json")
if ($LASTEXITCODE -ne 0) {
    throw "OpenAPI validation failed"
}

Write-Host "Checking generated SDK shape"
Assert-FileContains (Join-Path $Root "openapi.json") '"url" : "https://api.vectorizer.ai/api/v1"' "OpenAPI server URL"
Assert-FileContains (Join-Path $Root "output/python/vectorizer_ai/api/vectorization_api.py") "-> bytearray" "Python vectorization API"
Assert-FileContains (Join-Path $Root "output/typescript/src/apis/VectorizationApi.ts") "Promise<Blob>" "TypeScript vectorization API"
Assert-FileContains (Join-Path $Root "output/java/src/main/java/ai/vectorizer/api/VectorizationApi.java") "File postVectorize" "Java vectorization API"
Assert-FileContains (Join-Path $Root "output/csharp/src/Vectorizer.AI/Api/VectorizationApi.cs") "System.IO.Stream PostVectorize" "C# vectorization API"
Assert-FileContains (Join-Path $Root "output/go/go.mod") "module github.com/clv/vectorizer-go" "Go module path"
Assert-FileContains (Join-Path $Root "output/go/api_vectorization.go") "Execute() (*os.File" "Go vectorization API"
Assert-FileContains (Join-Path $Root "output/php/lib/Api/VectorizationApi.php") "public function postVectorize(`$associative_array)" "PHP vectorization API"
Assert-FileContains (Join-Path $Root "output/ruby/lib/vectorizer_ai/api/vectorization_api.rb") "@return [File]" "Ruby vectorization API"

$DeprecatedOutputs = @("bash", "dart", "kotlin", "powershell", "rust", "swift", "typescript-node")
foreach ($OutputName in $DeprecatedOutputs) {
    $OutputPath = Join-Path $Root "output/$OutputName"
    if (Test-Path -LiteralPath $OutputPath) {
        throw "Deprecated SDK output is still present: output/$OutputName"
    }
}

Write-Host "Checking curated SDK config set"
$ExpectedConfigs = @("csharp.yaml", "go.yaml", "java.yaml", "php.yaml", "python.yaml", "ruby.yaml", "typescript.yaml")
$ConfigNames = @(Get-ChildItem -LiteralPath (Join-Path $Root "config") -Filter "*.yaml" | ForEach-Object { $_.Name } | Sort-Object)
$UnexpectedConfigs = @($ConfigNames | Where-Object { $ExpectedConfigs -notcontains $_ })
if ($UnexpectedConfigs.Count -gt 0) {
    throw "Unexpected SDK config files: $($UnexpectedConfigs -join ', ')"
}
foreach ($ExpectedConfig in $ExpectedConfigs) {
    if ($ConfigNames -notcontains $ExpectedConfig) {
        throw "Missing SDK config file: $ExpectedConfig"
    }
}

Write-Host "Checking package metadata"
$TsPackage = Get-Content -LiteralPath (Join-Path $Root "output/typescript/package.json") -Raw | ConvertFrom-Json
if ($TsPackage.author -ne "Vectorizer.AI <support@vectorizer.ai>") {
    throw "Unexpected TypeScript package author: $($TsPackage.author)"
}
$Composer = Get-Content -LiteralPath (Join-Path $Root "output/php/composer.json") -Raw | ConvertFrom-Json
if ($Composer.name -ne "vectorizer/ai") {
    throw "Unexpected Composer package name: $($Composer.name)"
}
[xml]$CSharpProject = Get-Content -LiteralPath (Join-Path $Root "output/csharp/src/Vectorizer.AI/Vectorizer.AI.csproj") -Raw
if ($CSharpProject.Project.PropertyGroup.AssemblyTitle -ne "Vectorizer.AI API SDK") {
    throw "Unexpected C# package title: $($CSharpProject.Project.PropertyGroup.AssemblyTitle)"
}

Write-Host "Checking Python syntax"
& python -m compileall -q (Join-Path $Root "output/python/vectorizer_ai")
if ($LASTEXITCODE -ne 0) {
    throw "Python compileall failed"
}

if ($Deep) {
    Write-Host "Building TypeScript package"
    Push-Location (Join-Path $Root "output/typescript")
    try {
        & npm.cmd install
        if ($LASTEXITCODE -ne 0) { throw "npm install failed" }
        & npm.cmd run build
        if ($LASTEXITCODE -ne 0) { throw "npm run build failed" }
    } finally {
        Pop-Location
    }

    $Gradle = Join-Path $Root "output/java/gradlew.bat"
    if (Test-Path -LiteralPath $Gradle) {
        Write-Host "Building Java package"
        Push-Location (Join-Path $Root "output/java")
        try {
            & $Gradle assemble -x test --no-daemon
            if ($LASTEXITCODE -ne 0) { throw "Gradle build failed" }
        } finally {
            Pop-Location
        }
    }
}

if ($Deep -and !$KeepBuildArtifacts) {
    Write-Host "Cleaning local build artifacts"
    Remove-GeneratedArtifact (Join-Path $Root "output/typescript/node_modules")
    Remove-GeneratedArtifact (Join-Path $Root "output/typescript/dist")
    Remove-GeneratedArtifact (Join-Path $Root "output/typescript/package-lock.json")
    Remove-GeneratedArtifact (Join-Path $Root "output/java/.gradle")
    Remove-GeneratedArtifact (Join-Path $Root "output/java/build")
}

Write-Host "SDK checks completed"
