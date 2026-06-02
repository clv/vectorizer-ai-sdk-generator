[CmdletBinding()]
param(
    [string]$SpecUrl = "http://localhost:9000/api/openapi.json",
    [string]$SpecFile = "",
    [string]$Version = "1.0.0",
    [string[]]$Languages = @("python", "typescript", "java", "csharp", "go", "php", "ruby"),
    [switch]$SkipFetch,
    [switch]$NoClean,
    [switch]$KeepDeprecatedOutputs
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
if ([string]::IsNullOrWhiteSpace($SpecFile)) {
    $SpecFile = Join-Path $Root "openapi.json"
}

$GeneratorVersion = "7.6.0"
$JarName = "openapi-generator-cli-$GeneratorVersion.jar"
$Jar = Join-Path $Root $JarName
$JarUrl = "https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/$GeneratorVersion/$JarName"

if (!(Test-Path -LiteralPath $Jar)) {
    Write-Host "Downloading OpenAPI Generator CLI $GeneratorVersion..."
    Invoke-WebRequest -Uri $JarUrl -OutFile $Jar
}

if (!$SkipFetch) {
    Write-Host "Fetching OpenAPI spec from $SpecUrl"
    if ($SpecUrl -match "^https?://") {
        Invoke-WebRequest -Uri $SpecUrl -OutFile $SpecFile
    } else {
        Copy-Item -LiteralPath $SpecUrl -Destination $SpecFile -Force
    }
}

Write-Host "Validating $SpecFile"
& java -jar $Jar validate -i $SpecFile
if ($LASTEXITCODE -ne 0) {
    throw "OpenAPI validation failed"
}

$Definitions = [ordered]@{
    python = @{
        Generator = "python"
        Config = "config/python.yaml"
        Output = "output/python"
        Global = "apiTests=false,modelTests=false"
    }
    typescript = @{
        Generator = "typescript-fetch"
        Config = "config/typescript.yaml"
        Output = "output/typescript"
        Global = "apiTests=false,modelTests=false"
    }
    java = @{
        Generator = "java"
        Config = "config/java.yaml"
        Output = "output/java"
        Template = "custom-templates"
        Global = "apiTests=false,modelTests=false"
    }
    csharp = @{
        Generator = "csharp"
        Config = "config/csharp.yaml"
        Output = "output/csharp"
        Global = "apiTests=false,modelTests=false"
    }
    go = @{
        Generator = "go"
        Config = "config/go.yaml"
        Output = "output/go"
        Global = "apiTests=false,modelTests=false"
    }
    php = @{
        Generator = "php"
        Config = "config/php.yaml"
        Output = "output/php"
        Global = "apiTests=false,modelTests=false"
    }
    ruby = @{
        Generator = "ruby"
        Config = "config/ruby.yaml"
        Output = "output/ruby"
        Global = "apiTests=false,modelTests=false"
    }
}

$OutputRoot = [System.IO.Path]::GetFullPath((Join-Path $Root "output"))
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-TextFile($Path, $Text) {
    [System.IO.File]::WriteAllText($Path, $Text, $script:Utf8NoBom)
}

function Write-JsonFile($Path, $Value) {
    $Json = $Value | ConvertTo-Json -Depth 20
    $Json = $Json.Replace("\u003c", "<").Replace("\u003e", ">").Replace("\u0026", "&")
    Write-TextFile $Path $Json
}

function Update-TextFile($Path, $Replacements) {
    $Text = Get-Content -LiteralPath $Path -Raw
    foreach ($Replacement in $Replacements) {
        $Text = $Text.Replace($Replacement.From, $Replacement.To)
    }
    Write-TextFile $Path $Text
}

function Update-TextFileRegex($Path, $Pattern, $Replacement) {
    $Text = Get-Content -LiteralPath $Path -Raw
    $Text = [regex]::Replace($Text, $Pattern, $Replacement)
    Write-TextFile $Path $Text
}

function PostProcess-Sdk($Language, $Output) {
    Copy-Item -LiteralPath (Join-Path $Root "LICENSE") -Destination (Join-Path $Output "LICENSE") -Force
    @"
* text=auto eol=lf
*.bat text eol=crlf
"@ | ForEach-Object { Write-TextFile (Join-Path $Output ".gitattributes") $_ }

    switch ($Language) {
        "python" {
            Update-TextFile (Join-Path $Output "pyproject.toml") @(
                @{ From = 'name = "vectorizer_ai"'; To = 'name = "vectorizer-ai-sdk"' },
                @{ From = 'license = "Proprietary"'; To = 'license = "Apache-2.0"' }
            )
            Update-TextFile (Join-Path $Output "setup.py") @(
                @{ From = 'NAME = "vectorizer-ai"'; To = 'NAME = "vectorizer-ai-sdk"' },
                @{ From = 'license="Proprietary"'; To = 'license="Apache-2.0"' }
            )
        }
        "typescript" {
            $PackageJson = Join-Path $Output "package.json"
            $Package = Get-Content -LiteralPath $PackageJson -Raw | ConvertFrom-Json
            $Package.description = "Official TypeScript and JavaScript SDK for the Vectorizer.AI image vectorization API"
            $Package.author = "Vectorizer.AI <support@vectorizer.ai>"
            $Package | Add-Member -NotePropertyName license -NotePropertyValue "Apache-2.0" -Force
            Write-JsonFile $PackageJson $Package
        }
        "java" {
            $PomFile = Join-Path $Output "pom.xml"
            $PomText = Get-Content -LiteralPath $PomFile -Raw
            $PomText = [regex]::Replace($PomText, "(?m)^    <version>[^<]+</version>", "    <version>$Version</version>", 1)
            Write-TextFile $PomFile $PomText
            Update-TextFile $PomFile @(
                @{ From = "<name>Unlicense</name>"; To = "<name>Apache License, Version 2.0</name>" },
                @{ From = "<url>https://vectorizer.ai/policies/terms</url>"; To = "<url>https://www.apache.org/licenses/LICENSE-2.0.txt</url>" }
            )
            Update-TextFile (Join-Path $Output "build.gradle") @(
                @{ From = "version = '1.0.0'"; To = "version = '$Version'" },
                @{ From = "targetCompatibility = JavaVersion.VERSION_11"; To = "targetCompatibility = JavaVersion.VERSION_11`n`njava {`n    withSourcesJar()`n    withJavadocJar()`n}" }
            )
            Update-TextFileRegex (Join-Path $Output "build.gradle") "(?s)`ntasks\.register\('sourcesJar', Jar\) \{.*?artifacts \{\s+archives tasks\.named\('sourcesJar'\)\s+archives tasks\.named\('javadocJar'\)\s+\}\s+" "`n"
            Update-TextFile (Join-Path $Output "README.md") @(
                @{ From = "<version>1.0.0</version>"; To = "<version>$Version</version>" },
                @{ From = "ai.vectorizer:vectorizer-ai-java:1.0.0"; To = "ai.vectorizer:vectorizer-ai-java:$Version" },
                @{ From = "vectorizer-ai-java-1.0.0.jar"; To = "vectorizer-ai-java-$Version.jar" }
            )
        }
        "php" {
            $ComposerJson = Join-Path $Output "composer.json"
            $Composer = Get-Content -LiteralPath $ComposerJson -Raw | ConvertFrom-Json
            $Composer.name = "vectorizer/ai"
            $Composer.description = "Official PHP SDK for the Vectorizer.AI image vectorization API."
            $Composer.license = "Apache-2.0"
            $Composer.PSObject.Properties.Remove("version")
            Write-JsonFile $ComposerJson $Composer
            Update-TextFileRegex (Join-Path $Output "lib/HeaderSelector.php") "(?s)if \(![$]isMultipart\) \{\s+if\([$]contentType === ''\) \{\s+[$]contentType = 'application/json';\s+\}\s+[$]headers\['Content-Type'\] = [$]contentType;\s+\}" "if (!`$isMultipart && `$contentType !== '') {`n            `$headers['Content-Type'] = `$contentType;`n        }"
            Update-TextFileRegex (Join-Path $Output "lib/Api/AccountApi.php") "'getAccountStatus'\s*=>\s*\[\s*'application/json',\s*\]," "'getAccountStatus' => [`n            '',`n        ],"
        }
        "csharp" {
            $ProjectFile = Join-Path $Output "src/Vectorizer.AI/Vectorizer.AI.csproj"
            [xml]$Project = Get-Content -LiteralPath $ProjectFile -Raw
            $PropertyGroup = $Project.Project.PropertyGroup
            $PropertyGroup.AssemblyTitle = "Vectorizer.AI API SDK"
            $PropertyGroup.Copyright = "Copyright Vectorizer.AI"
            $PropertyGroup.PackageReleaseNotes = "Initial public SDK release."
            if ($null -eq $PropertyGroup.PackageLicenseExpression) {
                $Node = $Project.CreateElement("PackageLicenseExpression")
                $Node.InnerText = "Apache-2.0"
                $PropertyGroup.AppendChild($Node) | Out-Null
            } else {
                $PropertyGroup.PackageLicenseExpression = "Apache-2.0"
            }
            if ($null -eq $PropertyGroup.PackageProjectUrl) {
                $Node = $Project.CreateElement("PackageProjectUrl")
                $Node.InnerText = "https://vectorizer.ai/api/documentation#sdks"
                $PropertyGroup.AppendChild($Node) | Out-Null
            } else {
                $PropertyGroup.PackageProjectUrl = "https://vectorizer.ai/api/documentation#sdks"
            }
            if ($null -eq $PropertyGroup.PackageReadmeFile) {
                $Node = $Project.CreateElement("PackageReadmeFile")
                $Node.InnerText = "README.md"
                $PropertyGroup.AppendChild($Node) | Out-Null
            } else {
                $PropertyGroup.PackageReadmeFile = "README.md"
            }
            $HasReadmeItem = $false
            foreach ($ItemGroup in $Project.Project.ItemGroup) {
                foreach ($NoneItem in $ItemGroup.None) {
                    if ($NoneItem.Include -eq "..\..\README.md") {
                        $HasReadmeItem = $true
                    }
                }
            }
            if (!$HasReadmeItem) {
                $ItemGroup = $Project.CreateElement("ItemGroup")
                $NoneItem = $Project.CreateElement("None")
                $NoneItem.SetAttribute("Include", "..\..\README.md")
                $NoneItem.SetAttribute("Pack", "true")
                $NoneItem.SetAttribute("PackagePath", "\")
                $ItemGroup.AppendChild($NoneItem) | Out-Null
                $Project.Project.AppendChild($ItemGroup) | Out-Null
            }
            $Project.Save($ProjectFile)
        }
        "ruby" {
            $GemspecFile = Join-Path $Output "vectorizer_ai.gemspec"
            Update-TextFile $GemspecFile @(
                @{ From = 's.license     = "Unlicense"'; To = 's.license     = "Apache-2.0"' }
            )
            $RubyMetadata = @'
s.metadata    = {
    "source_code_uri" => "https://github.com/clv/vectorizer-ai-ruby",
    "documentation_uri" => "https://vectorizer.ai/api/documentation",
    "changelog_uri" => "https://github.com/clv/vectorizer-ai-ruby/releases",
    "rubygems_mfa_required" => "true"
  }
'@
            Update-TextFileRegex $GemspecFile 's\.metadata\s*=\s*\{\}' $RubyMetadata
            $RubyFileList = @'
  s.files         = [
    "Gemfile",
    "LICENSE",
    "README.md",
    "Rakefile",
    "vectorizer_ai.gemspec"
  ] + Dir.glob("docs/**/*.md") + Dir.glob("lib/**/*.rb")
  s.test_files    = Dir.glob("spec/**/*.rb")
'@
            Update-TextFileRegex $GemspecFile '(?s)  s\.files\s*=.*?  s\.test_files\s*=.*?\r?\n' ($RubyFileList + "`n")
            Update-TextFileRegex (Join-Path $Output "lib/vectorizer_ai/api_client.rb") "\s*'Content-Type' => 'application/json',\r?\n" "`n"
        }
    }

    foreach ($NoiseFile in @("git_push.sh", ".travis.yml", ".gitlab-ci.yml", "appveyor.yml")) {
        $NoisePath = Join-Path $Output $NoiseFile
        if (Test-Path -LiteralPath $NoisePath) {
            Remove-Item -LiteralPath $NoisePath -Force
        }
    }
    $GeneratedGithubWorkflows = Join-Path $Output ".github"
    if (Test-Path -LiteralPath $GeneratedGithubWorkflows) {
        Remove-Item -LiteralPath $GeneratedGithubWorkflows -Recurse -Force
    }
}

if (!$NoClean -and !$KeepDeprecatedOutputs) {
    $DeprecatedOutputs = @("bash", "dart", "kotlin", "powershell", "rust", "swift", "typescript-node")
    foreach ($OutputName in $DeprecatedOutputs) {
        $DeprecatedOutput = [System.IO.Path]::GetFullPath((Join-Path $OutputRoot $OutputName))
        if (!$DeprecatedOutput.StartsWith($OutputRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Refusing to clean output outside SDK output folder: $DeprecatedOutput"
        }
        if (Test-Path -LiteralPath $DeprecatedOutput) {
            Write-Host "Pruning deprecated SDK output output/$OutputName"
            Remove-Item -LiteralPath $DeprecatedOutput -Recurse -Force
        }
    }
}

foreach ($Language in $Languages) {
    if (!$Definitions.Contains($Language)) {
        throw "Unknown SDK language '$Language'. Known: $($Definitions.Keys -join ', ')"
    }

    $Definition = $Definitions[$Language]
    $Output = [System.IO.Path]::GetFullPath((Join-Path $Root $Definition.Output))
    if (!$Output.StartsWith($OutputRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Refusing to clean output outside SDK output folder: $Output"
    }

    if (!$NoClean -and (Test-Path -LiteralPath $Output)) {
        Write-Host "Cleaning $($Definition.Output)"
        Remove-Item -LiteralPath $Output -Recurse -Force
    }

    Write-Host "Generating $Language SDK"
    $Args = @(
        "-jar", $Jar,
        "generate",
        "-g", $Definition.Generator,
        "-i", $SpecFile,
        "-c", (Join-Path $Root $Definition.Config),
        "-o", $Output,
        "--global-property", $Definition.Global,
        "--additional-properties", "packageVersion=$Version,artifactVersion=$Version,npmVersion=$Version,gemVersion=$Version"
    )

    if ($Definition.Contains("Template")) {
        $Args += @("-t", (Join-Path $Root $Definition.Template))
    }

    & java @Args
    if ($LASTEXITCODE -ne 0) {
        throw "Generation failed for $Language"
    }

    PostProcess-Sdk $Language $Output
}

Write-Host "Generated SDKs: $($Languages -join ', ')"
