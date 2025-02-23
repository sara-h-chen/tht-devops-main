data "terraform_remote_state" "supporting_infra" {
  backend = "remote"

  config = {
    organization = "df-devops"
    workspaces = {
      name = "supporting-infrastructure"
    }
  }
}