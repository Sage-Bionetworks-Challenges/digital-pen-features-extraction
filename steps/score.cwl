#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Score predictions

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: pred_file
  type: File
  inputBinding:
    prefix: -p
- id: groundtruth_file
  type: File
  inputBinding:
    prefix: -g
- id: task_number
  type: string?
  inputBinding:
    prefix: -t
- id: check_validation_finished
  type: boolean?

outputs:
- id: results
  type: File
  outputBinding:
    glob: results.json
- id: status
  type: string
  outputBinding:
    glob: results.json
    outputEval: $(JSON.parse(self[0].contents)['submission_status'])
    loadContents: true

baseCommand:
- Rscript
- score.R
arguments:
- prefix: -o
  valueFrom: results.json

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn69926066/evaluation:v0.0
