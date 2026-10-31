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
- id: outcomes_file
  type: File
  inputBinding:
    prefix: --outcomes_file
- id: fhs_mapping_file
  type: File
  inputBinding:
    prefix: --fhs_mapping_file
- id: train_ids_file
  type: File
  inputBinding:
    prefix: --train_ids_file
- id: test_ids_file
  type: File
  inputBinding:
    prefix: --test_ids_file
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
- id: score_output_file
  type: File
  outputBinding:
    glob: output_list.RData

baseCommand: score.R
arguments:
- prefix: -o
  valueFrom: results.json

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn69926066/evaluation:v0.0
