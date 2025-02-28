$organization = "https://dev.azure.com/organizacao"
$pat = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
$headers = @{ Authorization = "Basic $( [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$pat")))" }

# Obter todos os projetos
$projects = Invoke-RestMethod -Uri "$organization/_apis/projects?api-version=7.1-preview.4" -Headers $headers

foreach ($project in $projects.value) {
    $projectName = $project.name
    $url = "$organization/$projectName/_apis/serviceendpoint/endpoints?api-version=7.1-preview.4"
    
    $endpoints = Invoke-RestMethod -Uri $url -Headers $headers
    $awsEndpoints = $endpoints.value | Where-Object { $_.type -eq "AWS" }

    if ($awsEndpoints) {
        $output = @()
        foreach ($endpoint in $awsEndpoints) {
            $serviceConnectionUrl = "$organization/$projectName/_settings/adminservices?resourceId=$($endpoint.id)"

            $output += [PSCustomObject]@{
                ProjectName = $projectName
                EndpointName = $endpoint.name
                EndpointUrl  = $serviceConnectionUrl
            }
        }
        $output | Format-Table -AutoSize
    }
}
