Jenkins uses a dynamic one-line inventory (e.g. -i "10.0.0.5,") built from credentials.
Optional: add static inventory files here for manual runs, e.g. ansible-playbook playbooks/deploy-jar.yml -i inventory/staging.ini -e deploy_jar_src=/path/to.jar
