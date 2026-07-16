.PHONY: preview validate fmt init plan

preview:
	python3 -m http.server 8080 --directory site

validate:
	./scripts/validate-site.sh
	cd infra && terraform fmt -check -recursive && terraform init -backend=false && terraform validate

fmt:
	terraform -chdir=infra fmt -recursive

init:
	terraform -chdir=infra init

plan:
	terraform -chdir=infra plan

