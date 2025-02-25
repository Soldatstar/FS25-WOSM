#!/bin/bash

# Define base directory based on the script's location
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define paths for terraform and ansible directories
TERRAFORM_DIR="$BASE_DIR/terraform"
ANSIBLE_DIR="$BASE_DIR/ansible"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.yml"
# Regions to process
REGIONS=("ZH" "LS")

# Function to generate dynamic Ansible inventory file
generate_inventory() {
    declare -A floating_ips
    declare -A private_ips
    
    for region in "${REGIONS[@]}"; do
        cd "$TERRAFORM_DIR/$region" || exit
        terraform apply -refresh-only
    
        # Get outputs for current region
        floating_ips["$region"]=$(terraform output -json nodes_floating_ips_nodes | jq -r '.[]')
        private_ips["$region"]=$(terraform output -json private_ips_nodes | jq -r '.[]')
    done

    cd "$BASE_DIR"

    # Start inventory file
    cat <<EOF > "$INVENTORY_FILE"
all:
  children:
EOF

    # Create entries for each region
    for region in "${REGIONS[@]}"; do
        readarray -t region_floating <<< "${floating_ips[$region]}"
        readarray -t region_private <<< "${private_ips[$region]}"
        
        cat <<EOF >> "$INVENTORY_FILE"
    ${region}_nodes:
      hosts:
EOF

        for i in "${!region_floating[@]}"; do
            node_num=$(printf "%02d" $((i+1)))
            cat <<EOF >> "$INVENTORY_FILE"
        ${region}-Node${node_num}:
          ansible_host: ${region_floating[$i]}
          private_ip: ${region_private[$i]}
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
        done
    done

    echo "Inventory file generated at $INVENTORY_FILE"
}

# Option 1: Apply Terraform and run Ansible playbooks
apply_and_deploy() {
    # Apply Terraform for both regions
    for region in "${REGIONS[@]}"; do
        echo "Applying Terraform for $region"
        cd "$TERRAFORM_DIR/$region" || exit
        terraform init
        terraform apply -auto-approve
    done

    generate_inventory

    # Check all servers
    for region in "${REGIONS[@]}"; do
        cd "$TERRAFORM_DIR/$region" || exit
        floating_ips_k8s=$(terraform output -json floating_ips_k8s | jq -r '.[]')
        readarray -t region_floating <<< "$floating_ips_k8s"
        
        for ip in "${region_floating[@]}"; do
            check_server "$ip"
        done
    done

    playbooks=(
      "replace_authorized_keys.yml"
    )

    # Run each playbook
    for playbook in "${playbooks[@]}"; do
        ansible-playbook -i "$INVENTORY_FILE" "$ANSIBLE_DIR/$playbook"
    done
}

check_server() {
    local ip="$1"
    local port=22
    while true; do
        if nc -z -w5 "$ip" "$port" &> /dev/null; then
            echo "Server $ip is reachable and SSH is ready."
            break
        else
            echo "Waiting for SSH on server $ip to be ready..."
        fi
        sleep 5
    done
}

# Option 2: Refresh Terraform and regenerate inventory
refresh_inventory() {
    generate_inventory
    echo "Inventory refreshed successfully."
}

# Option 3: deploy report
deploy_report(){
    ansible-playbook -i "$INVENTORY_FILE" "$ANSIBLE_DIR"/deploy_report.yml
}

# Option 4: Destroy Terraform resources
destroy_resources() {
    for region in "${REGIONS[@]}"; do
        echo "Destroying resources for $region"
        cd "$TERRAFORM_DIR/$region" || exit
        terraform destroy -auto-approve
    done
    echo "All Terraform resources destroyed."
}

# Main menu
echo "Select an option:"
echo "1) Apply Terraform and deploy Ansible playbooks"
echo "2) Refresh inventory"
echo "3) Deploy Report"
echo "4) Destroy Terraform resources"
read -p "Enter your choice (1-4): " choice

case $choice in
    1) apply_and_deploy ;;
    2) refresh_inventory ;;
    3) deploy_report ;;
    4) destroy_resources ;;
    *) echo "Invalid option." ;;
esac