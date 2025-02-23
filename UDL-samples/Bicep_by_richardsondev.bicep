/* 
  Test Bicep File for UDL Highlighting
  Keywords: metadata, targetScope, resource, module, param, var, output, for, in, if, existing, import, as, type, with, using, extends, func, assert, extension
  Also includes: true, false, null, and, or, not, any, concat, format, replace, split, uniqueString, resourceId, reference, json, int, bool, string, array, object, union, intersection, length, substring
*/

#disable-next-line what-if-short-circuiting

// Set the target scope for the deployment.
targetScope = 'subscription'

@description('The deployment location')
param location string = 'eastus'

@secure()
param adminPassword string

param adminUsername string = 'adminUser'

// Variable using built-in functions (Keywords8) and Keywords1 (concat, uniqueString)
var storageName = toLower(concat('stor', uniqueString(resourceGroup().id)))

// Examples of built-in functions (Keywords8)
var formattedString   = format('Storage Account: {0}', storageName)
var replacedString    = replace('Hello World', 'World', 'Bicep')
var splittedArray     = split('a,b,c', ',')
var resId             = resourceId('Microsoft.Storage/storageAccounts', storageName)
var refResult         = reference(resId)
var jsonResult        = json('{ "key": "value" }')
var intValue          = int('123')
var boolValue         = bool('true')
var stringValue       = string(456)
var arrayValue        = array(789)
var objectValue       = object('{ "a": 1 }')
var unionResult       = union([1,2,3], [4,5,6])
var intersectionResult= intersection([1,2,3,4], [3,4,5,6])
var lengthValue       = length([10,20,30])
var substringValue    = substring('Bicep${resId}', 1, 3)
var base64Text        = base64(inputString)

// Logical expressions using Keywords2 (true, false, null) and Keywords3 (and, or, not)
var condition = (location == 'eastus') ? true : false
var logicTest = (true and false) or not(true)
var anyValue  = any([null, false, 0])
var multiplication = 5*5

// Using a for-expression with Keywords1 (for, in)
var arrayOfValues = [for i in range(0, 3): i]

// Resource declaration using Keywords1 (resource, metadata)
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: storageName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  // (metadata used here as a comment for demonstration)
  /* metadata: This resource uses standard settings */
}

// Conditional resource deployment using Keywords1 (if)
resource conditionalResource 'Microsoft.Storage/storageAccounts@2021-04-01' = if (location == 'eastus') {
  name: concat(storageName, 'east')
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

// Referencing an existing resource using Keywords1 (existing)
resource existingVNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: 'myVnet'
}

// Module deployment using Keywords1 (module)
module networkModule 'network.bicep' = {
  name: 'networkDeploy'
  params: {
    location: location
  }
}

// Output declaration using Keywords1 (output)
output storageAccountId string = storageAccount.id

// Additional keywords (import, as, with, using, extends, func, assert, extension)
// are added here in comments for highlighting purposes.
//
// import, as, with, using, extends, func, assert, extension: These keywords are here solely for testing highlighting.
