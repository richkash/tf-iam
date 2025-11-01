variable "team_name" {
    description = "Team Env"
    type        = string
}

variable "users" {
    description = "List of Team members"
    type        = list(string)
}

variable "env" {
    description = "Environment"
    type        = string
}