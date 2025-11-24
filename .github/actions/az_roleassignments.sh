# Set variables (replace with your actual resource names after deployment)
RG_NAME="rg-ai-foundry-minimal-kn8fe" # Check the portal for the exact name
FOUNDRY_NAME="ai-foundry-o9lh"        # Check the portal for the exact name
KV_NAME="kv-foundry-kn8fe"            # Check the portal for the exact name
VM_NAME="ai-alz-jumpvm"               # Check the portal for the exact name
USER_ID="42396712-21bd-4768-8192-7a51246e97b4"

# Assign roles for AI Foundry
az role assignment create --assignee $USER_ID --role "Contributor" --scope "/subscriptions/18130d9b-e691-4be6-b9c8-5f75690853db/resourceGroups/$RG_NAME/providers/Microsoft.CognitiveServices/accounts/$FOUNDRY_NAME"
az role assignment create --assignee $USER_ID --role "Cognitive Services OpenAI Contributor" --scope "/subscriptions/18130d9b-e691-4be6-b9c8-5f75690853db/resourceGroups/$RG_NAME/providers/Microsoft.CognitiveServices/accounts/$FOUNDRY_NAME"
az role assignment create --assignee $USER_ID --role "Cognitive Services OpenAI User" --scope "/subscriptions/18130d9b-e691-4be6-b9c8-5f75690853db/resourceGroups/$RG_NAME/providers/Microsoft.CognitiveServices/accounts/$FOUNDRY_NAME"
az role assignment create --assignee $USER_ID --role "Azure AI Developer" --scope "/subscriptions/18130d9b-e691-4be6-b9c8-5f75690853db/resourceGroups/$RG_NAME/providers/Microsoft.CognitiveServices/accounts/$FOUNDRY_NAME"

# Assign role for Key Vault
az role assignment create --assignee $USER_ID --role "Key Vault Administrator" --scope "/subscriptions/18130d9b-e691-4be6-b9c8-5f75690853db/resourceGroups/$RG_NAME/providers/Microsoft.KeyVault/vaults/$KV_NAME"

# Assign role for Jump VM Login
az role assignment create --assignee $USER_ID --role "Virtual Machine Administrator Login" --scope "/subscriptions/18130d9b-e691-4be6-b9c8-5f75690853db/resourceGroups/$RG_NAME/providers/Microsoft.Compute/virtualMachines/$VM_NAME"
