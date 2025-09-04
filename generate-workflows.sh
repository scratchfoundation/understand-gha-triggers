#!/usr/bin/env bash
set -e

# This script aims to generate a workflow for every possible GHA workflow trigger (as listed in `events.txt`).
#
# The content in `events.txt` is hand-typed, using this page as reference:
# https://docs.github.com/en/actions/writing-workflows/choosing-when-your-workflow-runs/events-that-trigger-workflows
# Each line is an event that can trigger a workflow.
# If the event has multiple activity types, list them on the same line, separated by white-space.


# $1: event
# $2: optional activity type
make_workflow () {
	if [ -z "$2" ]; then
		echo "Making workflow for $1"
		workflow_id="$1"
	else
		echo "Making workflow for $1-$2"
		workflow_id="$1-$2"
	fi
	(
		echo "name: ${workflow_id}"
		echo ""
		echo "on:"
		echo "  $1:"
		if [ -n "$2" ]; then
			echo "    types: [$2]"
		fi
		echo ""
		echo "jobs:"
		echo "  foo:"
		echo "    name: ${workflow_id}"
		echo "    runs-on: ubuntu-latest"
		echo "    steps:"
		echo "      - name: Event context info"
		echo "        run: |"
		echo "          cat <<'EOF'"
		echo "          github: \${{toJSON(github)}}"
		echo "          env: \${{toJSON(env)}}"
		echo "          vars: \${{toJSON(vars)}}"
		echo "          job: \${{toJSON(job)}}"
		echo "          steps: \${{toJSON(steps)}}"
		echo "          runner: \${{toJSON(runner)}}"
		echo "          secrets: \${{toJSON(secrets)}}"
		echo "          strategy: \${{toJSON(strategy)}}"
		echo "          matrix: \${{toJSON(matrix)}}"
		echo "          needs: \${{toJSON(needs)}}"
		echo "          inputs: \${{toJSON(inputs)}}"
		echo "          EOF"
		echo "      - name: Dump environment"
		echo "        run: env"
	) > ".github/workflows/${workflow_id}.yaml"
}

mkdir -p .github/workflows/
while read event activity_types; do
	make_workflow "${event}"
	for activity_type in ${activity_types}; do
		make_workflow "${event}" "${activity_type}"
	done
done < events.txt
