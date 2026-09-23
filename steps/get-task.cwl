#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: ExpressionTool
label: Get inputDir path based on task number

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: queue
  type: string

outputs:
- id: input_dir
  type: string
expression: |2-

  ${

    // Task 1
    if (inputs.queue == "9616851") {
      return {
        input_dir: "/home/ec2-user/task1",
      };
    } 
    // Task 2
    else if (inputs.queue == "9616852") {
      return {
        input_dir: "/home/ec2-user/task2",
      }
    }
    else {
      throw 'invalid queue';
    }
  }