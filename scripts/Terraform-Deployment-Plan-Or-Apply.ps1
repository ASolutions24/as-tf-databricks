#test pipeline access
<#
Param(

[Parameter(Mandatory)]
[ValidateNotNullOrEmpty()]
[ValidateSet('dev','tst1','tst2','tst3','stage','prod')]
[string]$environmentName="dev",

[string]$appVersionToDeploy,

[string]$RequiredTerraformVersion = '1.3.6',

[ValidateSet('Plan','Apply')]
[string]$Plan_Or_Apply="Plan" )
#>

$RequiredTerraformVersion = '1.3.6'
$TFDownloadURL = "https://releases.hashicorp.com/terraform/" + $RequiredTerraformVersion +"/terraform_" + $RequiredTerraformVersion + "_windows_amd64.zip"

    $TerraformDeploymentPath = "$env:SYSTEM_ARTIFACTSDIRECTORY"+ "/content/terraform-templates/"
    Copy-item "$env:SYSTEM_ARTIFACTSDIRECTORY/tf-modules" "$env:SYSTEM_ARTIFACTSDIRECTORY/a/tf-modules" -recurse

Get-Childitem $env:SYSTEM_ARTIFACTSDIRECTORY -Recurse
Set-Location $TerraformDeploymentPath
#Copy-Item "env/$environmentName.tfvars" .
Copy-Item "env/terraform.tfvars" .

<#
  bkstrgrg: 'bktfstorageRG'
  bkstrg: 'asstgtfstate'
  bkcontainer: 'as-iac-tfstate'
  bkstrgkey: 'adfprodpipeline.terraform.tfstate'
#>
<#
-backend-config="storage_account_name=$env:TF_VAR_TFSTATE_STORAGE_ACCOUNT_NAME" `
-backend-config="container_name=$env:TF_VAR_TFSTATE_CONTAINER_NAME" `
-backend-config="key=$env:TF_VAR_TFSTATE_BACKEND_KEY" `
-backend-config="resource_group_name=$env:TF_VAR_TFSTATE_RESOURCE_GROUP_NAME"
#>

Invoke-WebRequest $TFDownloadURL -OutFile terraform.zip
Expand-Archive ./terraform.zip -DestinationPath .
./terraform version
./terraform init `
-backend-config="storage_account_name=asstgtfstate" `
-backend-config="container_name=as-iac-tfstate" `
-backend-config="key=adfprodpipeline.terraform.tfstate" `
-backend-config="resource_group_name=bktfstorageRG"

./terraform plan "-var-file=terraform.tfvars" -input=false -lock=false -out plan.out

<#
if($Plan_Or_Apply -eq "Plan")
{
    ./terraform plan "-var-file=terraform.tfvars" -input=false -lock=false -out plan.out
}elseif($Plan_Or_Apply -eq "Apply")
{
    ./terraform plan "-var-file=$environmentName.tfvars" -input=false -lock=false -out plan.out
    ./terraform apply plan.out -no-color
}
#>