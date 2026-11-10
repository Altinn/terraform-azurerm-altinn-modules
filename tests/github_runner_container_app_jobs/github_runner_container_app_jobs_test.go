package azure_devops_agent_container_app_jobs

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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
	verifyIdentityHiddenFromContainers(t, terraformOptions, subscriptionID)

	// identitySettings is set with azapi on a resource managed by azurerm. A
	// second plan must be empty, or the two providers fight over the job.
	assert.Equal(t, 0, terraform.PlanExitCode(t, terraformOptions), "plan after apply should have no changes")
}

func verifyContainerAppResourcesExists(t *testing.T, terraformOptions *terraform.Options, subscriptionID string) {
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	environmnetName := terraform.Output(t, terraformOptions, "environment_name")
	var runnerJobNames map[string]string
	terraform.OutputStruct(t, terraformOptions, "runner_job_names", &runnerJobNames)
	assert.True(t, azure.ManagedEnvironmentExists(t, environmnetName, resourceGroupName, subscriptionID))
	assert.True(t, azure.ContainerAppJobExists(t, runnerJobNames["terraform-azurerm-altinn-modules"], resourceGroupName, subscriptionID))
}

// The runner identity can read the GitHub App private key, so it must not be
// available to code running in the runner container.
func verifyIdentityHiddenFromContainers(t *testing.T, terraformOptions *terraform.Options, subscriptionID string) {
	resourceGroupName := terraform.Output(t, terraformOptions, "resource_group_name")
	var runnerJobNames map[string]string
	terraform.OutputStruct(t, terraformOptions, "runner_job_names", &runnerJobNames)

	job := azure.GetContainerAppJob(t, runnerJobNames["terraform-azurerm-altinn-modules"], resourceGroupName, subscriptionID)
	require.NotNil(t, job.Properties)
	require.NotNil(t, job.Properties.Configuration)

	settings := job.Properties.Configuration.IdentitySettings
	require.Len(t, settings, 1, "expected identitySettings for the runner identity")
	require.NotNil(t, settings[0].Lifecycle)
	assert.Equal(t, "None", string(*settings[0].Lifecycle))
}
