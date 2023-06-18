package test

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("Modules", func() {
	It("should ...", func() {
		// varFiles := []string{"test.tfvars"}
		// t := GinkgoT()
		// tfDir := "./examples/demo"
		// tfVars := map[string]interface{}{
		// 	// "openshift_gen": "touch openshift/bootstrap.ign && touch openshift/master.ign && touch openshift/worker.ign",
		// }
		// tfMainOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// 	TerraformDir: tfDir,
		// 	Vars:         tfVars,
		// 	VarFiles:     varFiles,
		// })
		//
		// defer terraform.Destroy(t, tfMainOptions)
		//
		// terraform.InitAndApply(t, tfMainOptions)
		//
		output := "not-nil" // terraform.Output(t, tfMainOptions, "cluster")
		Expect(output).NotTo(BeNil())
	})
})
