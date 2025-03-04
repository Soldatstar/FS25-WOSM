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

    # Clear the inventory file before writing new content
    > "$INVENTORY_FILE"

    # Start inventory file with the base structure
    cat <<EOF > "$INVENTORY_FILE"
all:
  children:
EOF

    for region in "${REGIONS[@]}"; do
        cd "$TERRAFORM_DIR/$region" || exit
        yes yes | terraform apply -refresh-only

        # Get outputs for current region
        readarray -t ceph_floating < <(terraform output -json floating_ips_ceph | jq -r '.[]')
        readarray -t ceph_private < <(terraform output -json private_ips_ceph | jq -r '.[]')
        readarray -t node_floating < <(terraform output -json nodes_floating_ips_nodes | jq -r '.[]')
        readarray -t node_private < <(terraform output -json private_ips_nodes | jq -r '.[]')

        cd "$BASE_DIR"

        # Write Ceph entries for the region
        cat <<EOF >> "$INVENTORY_FILE"
    ${region}_ceph:
      hosts:
EOF
        for i in "${!ceph_floating[@]}"; do
            node_num=$(printf "%02d" $((i+1)))
            cat <<EOF >> "$INVENTORY_FILE"
        ${region}-osd${node_num}:
          ansible_host: ${ceph_floating[$i]}
          private_ip: ${ceph_private[$i]}
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
        done

        # Write Node entries for the region
        cat <<EOF >> "$INVENTORY_FILE"
    ${region}_nodes:
      hosts:
EOF
        for i in "${!node_floating[@]}"; do
            node_num=$(printf "%02d" $((i+1)))
            cat <<EOF >> "$INVENTORY_FILE"
        ${region}-node${node_num}:
          ansible_host: ${node_floating[$i]}
          private_ip: ${node_private[$i]}
          ansible_ssh_common_args: '-o StrictHostKeyChecking=no'
EOF
        done
    done

    echo "Inventory file generated at $INVENTORY_FILE"
}

# ... [Rest of the script remains unchanged until the apply_and_deploy function]

# Option 1: Apply Terraform and run Ansible playbooks
apply_and_deploy() {
    # Apply Terraform for both regions
    for region in "${REGIONS[@]}"; do
        echo "Applying Terraform for $region"
        cd "$TERRAFORM_DIR/$region" || exit
        terraform init
        terraform apply -auto-approve
    done

    # Generate inventory after Terraform applies
    generate_inventory

    # Check all servers (updated to check both Ceph and Nodes)
    for region in "${REGIONS[@]}"; do
        cd "$TERRAFORM_DIR/$region" || exit
        # Check Ceph nodes
        readarray -t ceph_floating < <(terraform output -json floating_ips_ceph | jq -r '.[]')
        for ip in "${ceph_floating[@]}"; do
            check_server "$ip"
        done
        # Check regular nodes
        readarray -t node_floating < <(terraform output -json nodes_floating_ips_nodes | jq -r '.[]')
        for ip in "${node_floating[@]}"; do
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