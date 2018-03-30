# 1. Login to Azure.
Login-AzureRmAccount

# 2. Get the Subscription Id
Get-AzureRmSubscription

# 3. Use the Subscription Id from the previous cmdlet
Set-AzureRmContext -SubscriptionId xxx

# 4. Create a new ResourceGroup and a KeyVault
New-AzureRmResourceGroup -Name eastus-CompanyNamePhoenixkeyvaultResources -Location 'East US'
New-AzureRmKeyVault -VaultName 'CompanyNamePhoenixkeyvault' -ResourceGroupName 'eastus-CompanyNamePhoenixkeyvaultResources' -Location 'East US' -EnabledForDeployment

# 5. Import Module for Service Fabric
Import-Module "C:\Sfx\Service-Fabric-master\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"

# 6. Create a Self signed certificate and add it to the Vault
$ResourceGroup = "eastus-CompanyNamePhoenixkeyvaultResources"
$VName = "CompanyNamePhoenixkeyvault"
$SubID = ""
$locationRegion = "eastus"
$newCertName = "CompanyNamePhoenixCert"
$dnsName = "www.customdomain.com"      #The certificate's subject name must match the domain used to access the Service Fabric cluster.
$localCertPath = "C:\Sfx\certificates" # location where you want the .PFX to be stored

 Invoke-AddCertToKeyVault -SubscriptionId $SubID -ResourceGroupName $ResourceGroup -Location $locationRegion -VaultName $VName -CertificateName $newCertName -CreateSelfSignedCertificate -DnsName $dnsName -OutputPath $localCertPath

 # 7. AD Authentication for Web and the Client access
 C:\Sfx\AADTool\SetupApplications.ps1 -TenantId '' -ClusterName '' -WebApplicationReplyUrl 'https://customdomain.com:19080/Explorer/index.html'

 # 8. Create a new Resource Group for SF 
 New-AzureRmResourceGroup -Name MedsysPhoenixSfResources -Location 'East US'
 
 # 9. Test and Create the secured Service Fabric Cluster 
 Test-AzureRmResourceGroupDeployment -ResourceGroupName "CompanyNamePhoenixSfResources" -TemplateFile C:\Sf\service-fabric-secure-cluster-5-node-1-nodetype\azuredeploy.json -TemplateParameterFile C:\sf\service-fabric-secure-cluster-5-node-1-nodetype\azuredeploy.parameters.json

 New-AzureRmResourceGroupDeployment -ResourceGroupName "CompanyNamePhoenixSfResources" -TemplateFile C:\Sf\service-fabric-secure-cluster-5-node-1-nodetype\azuredeploy.json -TemplateParameterFile C:\sf\service-fabric-secure-cluster-5-node-1-nodetype\azuredeploy.parameters.json