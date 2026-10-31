#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Send email with results

requirements:
- class: InlineJavascriptRequirement
- class: InitialWorkDirRequirement
  listing:
  - entryname: email_results.py
    entry: |
      #!/usr/bin/env python
      import synapseclient
      import argparse
      import json
      import os
      parser = argparse.ArgumentParser()
      parser.add_argument("-s", "--submissionid", required=True, help="Submission ID")
      parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")
      parser.add_argument("--status", help="validation status")
      parser.add_argument("--submission_errors", default="", help="submission error details")

      args = parser.parse_args()
      syn = synapseclient.Synapse(configPath=args.synapse_config)
      syn.login()

      sub = syn.getSubmission(args.submissionid)
      participantid = sub.get("teamId")
      if participantid is not None:
        name = syn.getTeam(participantid)['name']
      else:
        participantid = sub.userId
        name = syn.getUserProfile(participantid)['userName']
      evaluation = syn.getEvaluation(sub.evaluationId)

      subject = f"Submission to '{evaluation.name}' "
      message = [f"Hello {name},\n\n"]
      if args.status == 'INVALID':
        subject += "invalid"
        message.append(args.submission_errors)
      else:
        subject += "accepted"
        message.append(
            "Thank you for participating in the Digital Pen Feature Extraction Challenge!\n\n"
            f"We have received your Docker model (Submission ID: {args.submissionid}). Your container has "
            "passed our preliminary check and executed successfully on a small subset of the data.\n\n"
            "<b>Please note:</b> A successful run on this minimal sample confirms basic execution, but does "
            "not guarantee success on the full evaluation test set. Final scoring will depend on your container "
            "completing the entire held-out dataset."
        )
      message.append(
        "\n\n"
        "From the Challenge Organizing Team"
      )
      syn.sendMessage(
        userIds=[participantid],
        messageSubject=subject,
        messageBody="".join(message),
      )

inputs:
- id: submissionid
  type: int
- id: synapse_config
  type: File
- id: status
  type: string
- id: submission_errors
  type: string
  default: ""

outputs:
- id: finished
  type: boolean
  outputBinding:
    outputEval: $( true )

baseCommand: python3
arguments:
- valueFrom: email_results.py
- prefix: -s
  valueFrom: $(inputs.submissionid)
- prefix: -c
  valueFrom: $(inputs.synapse_config.path)
- prefix: --status
  valueFrom: $(inputs.status)
- prefix: --submission_errors
  valueFrom: $(inputs.submission_errors)

hints:
  DockerRequirement:
    dockerPull: sagebionetworks/synapsepythonclient:v4.9.0
