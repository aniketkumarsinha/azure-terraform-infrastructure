<div align="center"><h1>Deploy Azure Infrastructure using Terraform Cloud</h1></div>

![Cover Image](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/c66wndih4aa43cf493vd.png)

```
Note: Tried of creating this doc as a demo with all process/steps in creating this project
```

## What is Terraform?
[Terraform](https://www.terraform.io/) is an infrastructure as code tool that lets you define both cloud and on-prem resources in human-readable configuration files that you can version, reuse, and share.

### Terraform Flow
- First you have the terraform code.
- Then we have Terraform Plan phase. The terraform plan command creates an execution plan, which lets you preview the changes that Terraform plans to make to your infrastructure.
- Terraform Apply phase executes the actions proposed in a Terraform plan.
- And everything gets deployed over the CSP, here Azure.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/odtun8rbj9hgsb9brhuq.png)

## What is Terraform Cloud?
[Terraform Cloud](https://cloud.hashicorp.com/products/terraform) is a managed service offering by HashiCorp that eliminates the need for unnecessary tooling and documentation for practitioners, teams, and organizations to use Terraform in production. It allows you to provision infrastructure in a remote environment that is optimized for the Terraform workflow.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/7w2ijyuk5x6rrqy99gd1.png)

In this project, we will be creating Azure Infrastructure using Terraform and will be deploying it over to Azure using Terraform Cloud.

## Infrastructure Code
We are creating a VM and resources related to it. 
```
# Configure Azure Provider
terraform {
  required_providers {
     azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 3.59.0"
    } 
  }
  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}

  skip_provider_registration = "true"
}

variable "prefix" {
  default = "terraform"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-ResourceGroup"
  location = "Central India"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-VNet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "internal" {
  name                 = "${var.prefix}-internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-NIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "tfconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "vm" {
  name                  = "${var.prefix}-vm"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_DS1_v2"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "tfadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}
```

## Setting up Terraform Cloud

1. Create Terraform Cloud Account - [Terraform Cloud](https://www.hashicorp.com/products/terraform)
2. Create a Project in Terraform Cloud:
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/y949ss9lexpd5ridhozu.png)
3. Create a Workspace.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/wdde76gof5yxc8vp1kpw.png)
   - Choose Version control workflow
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/n1gp6u6x1mez3kdvbt8n.png)
   - Connect to a version control provider
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/a8bat7opbkli0x9t1yrj.png)
   - Choose your Azure Infrastructure repository from your repository list. You can check the advance settings if you want to configure the workflow.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/kd5dop1al2pugnalmqew.png)
   - Tap on **Create Workspace** button to create your workspace in terraform cloud Or Start new run from workspace overview page.
4. You can directly start your plan phase.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/ht6c0c2krj3o8wzmwgnk.png)
5. You can verify in your projects page that your workspace has been created.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/osfgv461t6slsonxjoo3.png)
6. Open your workspace to start new run.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/u1z112gu2ntqq8nuz5vx.png)
7. Choose your run type and start run.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/q263knx3mxpb9lfj3ith.png)
8. Ouch!! Errors!!
   We are getting error in provider phase. The reason behind this is that we have authorized our infrastructure to connect and write over our Azure. We will be creating an App provide all the necessary details to our infrastructure.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/0178a4rs54hqgjtjam3o.png)

## Authorizing Terraform Infrastructure to write over Azure
- We are creating an App over Azure to authorize using Client Id, Client Secret and Tenant Id. So in your [Azure Portal](https://portal.azure.com/) move into Azure Active Directory, and open `App registrations` from left pane, And add a new registration.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/4p1bc3pibj9hfog28oef.png)
- Add your App details and register.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dja5n5a5hmppgm3alwsq.png)
- So we have finally created our app.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/c42vlbil4aviwcvtwqck.png)
- To connect our Infrastructure we need 4 details:
  - Client Id
  - Client Secret
  - Tenant Id
  - Subscription Id
We would be getting this one by one.
- `Application (client) ID` is Client Id.
  `Directory (tenant) ID` is Tenant Id.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/n01jcz1nqjwwn4zjv0nu.png)
- To get the Client Secret, we first need to create the secret.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/j8zkh7k7zylxbporn2cx.png)
 - Add description and expiry of this secret which you're creating.
 - Copy this value under Value column, and save it somewhere as we wouldn't be able to access this later. This is our Client secret.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/yggxgu21wa9o97nf315n.png)
- Search Subscription from search box and open your subscription. Copy your subscription id.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/l4jmyk0g0p57mwqr518k.png)
So now we have all the required values.
- Let's add these values in our Infrastructure.
 - In the provider block add all four details. We would be saving the values in Terraform Cloud variables for security purpose.
```
provider "azurerm" {
  features {}

  skip_provider_registration = "true"
  
  # Connection to Azure
  subscription_id = var.subscription_id
  client_id = var.client_id
  client_secret = var.client_secret
  tenant_id = var.tenant_id
}
```
 - Add variables in Variables page.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/giji6tny99ldozgyp2yb.png)
  - In `Key` add the words with var, i.e., var.`key`, and in `Value` add required Ids' and Secret.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/jns0v92i8f6phwqqt8c2.png)

Let's rerun the workflow!

Ohhhhh!!!! ERROR AGAIN!!!!
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/pte3o0sq7lmlo9i8vem0.png)

But we are still left with some more code :P
We need to add variables.tf file mentioning about these variables.
```
variable "client_id" {
  type = string
}

variable "client_secret" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "tenant_id" {
  type = string
}
```


And now finally we can get the results from Plan and Apply phase. Let's rerun the pipeline.
- Wohooo!! Our Plan phase ran successfully:
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/or808kgvinu7t4hefah4.png)
- Expand Plan phase to check what resources are getting created. And if every configuration is fine then tap on `Confirm & Apply` button at the end of phase. So by default the Apply phase does not run automatically, we need manual approval, this is to make sure that someone checks the Plan output and verifies everything and then accordingly approve for Apply or reject.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/d1i9t9fbo1ggnxa2mxea.png)
- Error again 🫠
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/b359xrmnrnllyu5a813y.png)
- It seems our Azure app don't have permission to add anything. Let's provide the contributor role to our app.
 - Under Subscription, got to Access Control (IAM) and Add a role there.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/p31hlbpe9xfj2wwl8g4l.png)
 - Add a `Contributor` role under Privileged administrator roles.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/dt9iw8nusgjp2thbkf9w.png)
 - Under Members tab, select our app as member.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/21huwn8l97928mwqcqs8.png)
 - And then tap on Review+Assign. So now our App has contributor role and can make changes over Azure subscription.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/2lk9ervpboi0xnof2cjx.png)
- Rerun the pipeline. And wollaahh!!
Everything ran successfully!
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/3fdkhg2fmcbwawd2skq9.png)

Let's confirm over our Azure Portal too. 
Yes we can see all our resources present under our subscription.
![Image description](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/eyp2ult5uid4uerv6tmp.png)


 

































