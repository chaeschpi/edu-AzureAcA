param location string = resourceGroup().location
param envName string = 'blog-sample'

param containerImage string = 'demowebsite:latest'
param containerPort int = 80 







resource acr 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: 'acrdemoeuw9986'
  scope: resourceGroup('rg-acr-euw')
}


module law 'law.bicep' = {
    name: 'log-analytics-workspace'
    params: {
      location: location
      name: 'law-${envName}'
    }
}

module containerAppEnvironment 'environment.bicep' = {
  name: 'container-app-environment'
  params: {
    name: envName
    location: location
    lawClientId:law.outputs.clientId
    lawClientSecret: law.outputs.clientSecret
  }
}

module containerApp 'containerapp.bicep' = {
  name: 'sample'
  params: {
    name: 'sample-app'
    location: location
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerImage: containerImage
    containerPort: containerPort
    envVars: [
        {
        name: 'ASPNETCORE_ENVIRONMENT'
        value: 'Production'
        }
    ]
    useExternalIngress: true
    registry: acr.properties.loginServer
    registryUsername: acr.listCredentials().username
    registryPassword: acr.listCredentials().passwords[0].value

  }
}
output fqdn string = containerApp.outputs.fqdn

