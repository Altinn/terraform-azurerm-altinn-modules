package azure_devops_agent_container_app_jobs

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"k8s.io/utils/env"
)

func TestAzureDevopsAgentContainerAppJob(t *testing.T) {
	t.Parallel()

	subscriptionID := env.GetString("ARM_SUBSCRIPTION_ID", "fail")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"pat":             "NotARealPat",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	verifyNonModuleResourcesExists(t, terraformOptions, subscriptionID)

	verifyContainerAppResourcesExists(t, terraformOptions, subscriptionID)

}

func verifyNonModuleResourcesExists(t *testing.T, terraformOptions *terraform.Options, subscriptionID string) {
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	vnetName := terraform.Output(t, terraformOptions, "virtual_network_name")
	subnetName := terraform.Output(t, terraformOptions, "subnet_name")
	assert.True(t, azure.ResourceGroupExists(t, resourceGroupName, subscriptionID))
	assert.True(t, azure.VirtualNetworkExists(t, vnetName, resourceGroupName, subscriptionID))
	assert.True(t, azure.SubnetExists(t, subnetName, vnetName, resourceGroupName, subscriptionID))
}

func verifyContainerAppResourcesExists(t *testing.T, terraformOptions *terraform.Options, subscriptionID string) {
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	environmnetName := terraform.Output(t, terraformOptions, "environment_name")
	placeholderJobName := terraform.Output(t, terraformOptions, "placeholder_job_name")
	agentJobName := terraform.Output(t, terraformOptions, "agent_job_name")
	assert.True(t, azure.ManagedEnvironmentExists(t, environmnetName, resourceGroupName, subscriptionID))
	assert.True(t, azure.ContainerAppJobExists(t, placeholderJobName, resourceGroupName, subscriptionID))
	assert.True(t, azure.ContainerAppJobExists(t, agentJobName, resourceGroupName, subscriptionID))
}
