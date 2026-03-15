COMPONENT_SCRIPT := scripts/tf-stack.sh

platform-plan-test:
	bash $(COMPONENT_SCRIPT) platform test plan

platform-apply-test:
	bash $(COMPONENT_SCRIPT) platform test apply

database-plan-test:
	bash $(COMPONENT_SCRIPT) database test plan

database-apply-test:
	bash $(COMPONENT_SCRIPT) database test apply

runtime-plan-test:
	bash $(COMPONENT_SCRIPT) runtime test plan

runtime-apply-test:
	bash $(COMPONENT_SCRIPT) runtime test apply

all-plan-test:
	bash $(COMPONENT_SCRIPT) platform test plan
	bash $(COMPONENT_SCRIPT) database test plan
	bash $(COMPONENT_SCRIPT) runtime test plan

all-apply-test:
	bash $(COMPONENT_SCRIPT) platform test apply
	bash $(COMPONENT_SCRIPT) database test apply
	bash $(COMPONENT_SCRIPT) runtime test apply

all-destroy-test:
	bash $(COMPONENT_SCRIPT) runtime test destroy
	bash $(COMPONENT_SCRIPT) database test destroy
	bash $(COMPONENT_SCRIPT) platform test destroy

platform-plan-prod:
	bash $(COMPONENT_SCRIPT) platform prod plan

platform-apply-prod:
	bash $(COMPONENT_SCRIPT) platform prod apply

database-plan-prod:
	bash $(COMPONENT_SCRIPT) database prod plan

database-apply-prod:
	bash $(COMPONENT_SCRIPT) database prod apply

runtime-plan-prod:
	bash $(COMPONENT_SCRIPT) runtime prod plan

runtime-apply-prod:
	bash $(COMPONENT_SCRIPT) runtime prod apply

all-plan-prod:
	bash $(COMPONENT_SCRIPT) platform prod plan
	bash $(COMPONENT_SCRIPT) database prod plan
	bash $(COMPONENT_SCRIPT) runtime prod plan

all-apply-prod:
	bash $(COMPONENT_SCRIPT) platform prod apply
	bash $(COMPONENT_SCRIPT) database prod apply
	bash $(COMPONENT_SCRIPT) runtime prod apply

all-destroy-prod:
	bash $(COMPONENT_SCRIPT) runtime prod destroy
	bash $(COMPONENT_SCRIPT) database prod destroy
	bash $(COMPONENT_SCRIPT) platform prod destroy
