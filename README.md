# Digital Pen Features Extraction Challenge Infrastructure

Repository containing the technical infrastructure and code for the
Digital Pen Features Extraction Challenge (link coming soon).

The challenge infrastructure is powered by the [SynapseWorkflowOrchestrator]
orchestration tool, which continuously monitors the challenge for new submissions,
automatically processing and evaluating them using the steps defined in `workflow.cwl`.

### Folder Structure

```
digital-pen-features-extraction
├── evaluation      // core scoring and validation scripts
├── README.md
├── scripts         // scripts called by the individual CWL scripts
├── steps           // individual CWL scripts (called by the main workflow CWL)
└── workflow.cwl    // CWL workflow for evaluating submissions
```

## Evaluation Overview

_More details coming soon_
