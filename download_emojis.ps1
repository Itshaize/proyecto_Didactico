$emojis = @{
    "colors/black" = "2b1b";
    "colors/yellow" = "1f7e8";
    "colors/blue" = "1f7e6";
    "colors/red" = "1f7e5";
    "colors/brown" = "1f7eb";
    "colors/pink" = "1fa77"; 
    "colors/orange" = "1f7e7";
    "colors/green" = "1f7e9";
    "colors/white" = "2b1c";
    "colors/purple" = "1f7ea";
    "numbers/one" = "31-20e3";
    "numbers/two" = "32-20e3";
    "numbers/three" = "33-20e3";
    "numbers/four" = "34-20e3";
    "numbers/five" = "35-20e3";
    "numbers/six" = "36-20e3";
    "numbers/seven" = "37-20e3";
    "numbers/eight" = "38-20e3";
    "numbers/nine" = "39-20e3";
    "numbers/ten" = "1f51f";
}

$baseUrl = "https://cdnjs.cloudflare.com/ajax/libs/twemoji/14.0.2/svg/"
$destPath = "c:\Users\Ismal\eclipse-workspace\proyecto\src\main\webapp\images"

foreach ($key in $emojis.Keys) {
    $code = $emojis[$key]
    $url = "$baseUrl$code.svg"
    $targetFile = "$destPath\$key.svg"
    try {
        Invoke-WebRequest -Uri $url -OutFile $targetFile -UseBasicParsing
    } catch {
        # Fallback for pink heart if pink square not available
        if ($key -eq "colors/pink") {
            Invoke-WebRequest -Uri "$baseUrl/1f497.svg" -OutFile $targetFile -UseBasicParsing
        }
    }
}
