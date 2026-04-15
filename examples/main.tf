provider "aws" {
  region = "eu-west-2"
}

module "template" {
  source = "../"
  # source = "github.com/ministryofjustice/container-platform-terraform-template?ref=version" # use the latest release

}
