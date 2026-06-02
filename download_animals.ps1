$emojisAnimals = @{
    "animals/dog" = "1f436";
    "animals/cat" = "1f431";
    "animals/horse" = "1f434";
    "animals/bird" = "1f426";
    "animals/lion" = "1f981";
    "animals/butterfly" = "1f98b";
    "animals/rabbit" = "1f430";
    "animals/frog" = "1f438";
    "animals/elephant" = "1f418";
    "animals/fish" = "1f41f";
}
$baseUrl = "https://cdnjs.cloudflare.com/ajax/libs/twemoji/14.0.2/svg/"
$destPath = "c:\Users\Ismal\eclipse-workspace\proyecto\src\main\webapp\images"

foreach ($key in $emojisAnimals.Keys) {
    $code = $emojisAnimals[$key]
    $url = "$baseUrl$code.svg"
    $targetFile = "$destPath\$key.svg"
    try {
        Invoke-WebRequest -Uri $url -OutFile $targetFile -UseBasicParsing
    } catch {
        Write-Host "Failed to download $key ($url)"
    }
}
