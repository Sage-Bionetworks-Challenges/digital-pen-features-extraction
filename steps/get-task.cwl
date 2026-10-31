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

    // Task 1: command
    if (inputs.queue == "9616851") {
      return {
        input_dir: "/home/ec2-user/fastlane/task1",
      };
    } 
    // Task 2: copy
    else if (inputs.queue == "9616852") {
      return {
        input_dir: "/home/ec2-user/fastlane/task2",
      }
    }
    else {
      throw 'invalid queue';
    }
  }