#Connect to Azure
AzureADPreview\Connect-AzureAD

#Create Azure AD Policy
#We are adding onpremisessamaccountname here
New-AzureADPolicy -Definition @('{

                    "ClaimsMappingPolicy": {

                        "Version": 1,

                        "IncludeBasicClaimSet": "true",

                        "ClaimsSchema": [{

                              

                                 "Source": "user",

                                 "ID": "onpremisessamaccountname",

                                 "JwtClaimType": "onpremisessamaccountname"

                             }

                         

                         ]

                     }

               }') -DisplayName "JamfConnectClaimsPolicy1" -Type "ClaimsMappingPolicy"

#Get Jamf Connect object ID ###: ID1
Get-AzureADServicePrincipal -SearchString "jamf connect" | Select-Object ObjectId

#Get ID of claims policy ###: ID2
Get-AzureADPolicy | Select-String "JamfConnectClaimsPolicy1"

#Assign Azure AD claims mapping policy
#Add-AzureADServicePrincipalPolicy -Id “object id of jamf connect app” -RefObjectId “Id of claims policy”
#Add-AzureADServicePrincipalPolicy -Id “ID1” -RefObjectId “ID2”

#Remove Azure AD claims mapping policy
#Remove-AzureADServicePrincipalPolicy -Id “object id of jamf connect app” -PolicyId “Id of claims policy”
#Remove-AzureADServicePrincipalPolicy -Id “ID1” -PolicyId “ID2”

#Download the jamf connect app manifest file from AzureAD and modify this line "acceptMappedClaims": null, to "acceptMappedClaims": true,
echo "Make sure to download the jamf connect app manifest file from Azure and change this value at the top of the file "acceptMappedClaims": true,"