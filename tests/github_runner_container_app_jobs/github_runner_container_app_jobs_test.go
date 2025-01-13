package azure_devops_agent_container_app_jobs

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"k8s.io/utils/env"
)

func TestGithubRunnerContainerAppJob(t *testing.T) {
	t.Parallel()

	subscriptionID := env.GetString("ARM_SUBSCRIPTION_ID", "fail")

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: ".",
		Vars: map[string]interface{}{
			"key": "NotARealKey",
		},
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	verifyContainerAppResourcesExists(t, terraformOptions, subscriptionID)

}

func verifyContainerAppResourcesExists(t *testing.T, terraformOptions *terraform.Options, subscriptionID string) {
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	environmnetName := terraform.Output(t, terraformOptions, "environment_name")
	var runnerJobNames map[string]string
	terraform.OutputStruct(t, terraformOptions, "runner_job_names", &runnerJobNames)
	t.Log("Runner Job Names:")
	for k, runnerJobName := range runnerJobNames {
		t.Logf("%s: %s", k, runnerJobName)
	}
	assert.True(t, azure.ManagedEnvironmentExists(t, environmnetName, resourceGroupName, subscriptionID))
	assert.True(t, azure.ContainerAppJobExists(t, runnerJobNames["terraform-azurerm-altinn-modules"], resourceGroupName, subscriptionID))
}
