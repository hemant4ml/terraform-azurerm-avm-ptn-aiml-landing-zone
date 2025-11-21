# Cost Estimate Guide for AI Foundry Landing Zone (Minimal)

Since `infracost` is not installed in your environment, here is a manual breakdown of the estimated costs for the resources currently configured in your `terraform plan`.

## Estimated Monthly Costs (Approximate)

| Resource | SKU / Configuration | Estimated Cost (Monthly) | Notes |
| :--- | :--- | :--- | :--- |
| **Azure AI Foundry Hub** | S0 | Free / Usage-based | The hub itself is often free; costs come from attached resources and model usage. |
| **Azure AI Project** | S0 | Free / Usage-based | Similar to the hub. |
| **Storage Account** | Standard ZRS (Hot) | ~$0.06 per GB | ZRS is more expensive than LRS. Costs depend on data stored. |
| **Key Vault** | Premium | ~$3.00 + Operations | Premium SKU includes HSM-backed keys. Standard is cheaper (~$0.03) if HSM is not needed. |
| **Log Analytics** | PerGB2018 | ~$2.30 per GB ingested | Costs depend entirely on how much log data is generated. |
| **Private Endpoints** | Standard | ~$7.30 per endpoint | You have endpoints for Storage, Key Vault, etc. (Approx $20-$30 total). |
| **Data Processing** | Inbound/Outbound | ~$0.01 per GB | Charged for data going through Private Endpoints. |

**Total Estimated Base Cost:** ~$30 - $50 USD / month (excluding heavy usage/storage).

> **Note:** This does not include the cost of deploying/running AI Models (GPT-4, etc.), which are billed based on token usage.

## How to get a precise estimate

To get a precise estimate based on your Terraform plan, we recommend installing **Infracost**.

### 1. Install Infracost
```bash
brew install infracost
```

### 2. Authenticate
```bash
infracost auth login
```

### 3. Run Estimate
Run this command in your `deploy` directory:
```bash
infracost breakdown --path .
```

This will parse your Terraform code and plan to generate a detailed line-item invoice.
