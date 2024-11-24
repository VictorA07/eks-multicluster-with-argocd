#!/bin/bash

# List of Terraform workspaces to apply
workspaces=("argocd" "dev" "prod")

for workspace in "${workspaces[@]}"; do
  echo "Switching to workspace: $workspace"
  terraform workspace select "$workspace"

  echo "Running terraform apply on workspace: $workspace"
  terraform apply -auto-approve
done

echo "All workspaces have been applied."
