#!/usr/bin/env python

"""Validation script for digital pen features extraction submissions.

Validation checks include:
- `filename` column is present and contains strings
- File contains at least one feature column
- File is not empty
- Feature columns do not contain NaN values
"""
import json

import pandas as pd
import typer
from typing_extensions import Annotated

ID_COLUMN = "filename"


def check_feature_columns(file_cols: pd.Index) -> str:
    """Validates that the file has at least one feature column."""
    if len(file_cols) == 0:
        return "Features file does not contain any feature columns."
    return ""


def check_nan_columns(df: pd.DataFrame) -> str:
    """Validates that columns do not contain NaN values."""
    nan_cols = []

    # Check if index contains NaNs
    if df.index.isna().any():
        nan_cols.append(df.index.name or ID_COLUMN)

    # Check data columns for NaNs
    if cols_with_nan := df.columns[df.isna().any()].tolist():
        nan_cols.extend(cols_with_nan)

    if nan_cols:
        return f"Found NaN values in the following columns: {nan_cols}."
    return ""


def validate(pred_file: str) -> list[str]:
    errors = []
    try:
        pred = pd.read_csv(
            pred_file,
            float_precision="round_trip",
        ).set_index(ID_COLUMN)
    except KeyError:
        errors.append("Features file is missing the required 'filename' column.")
    except pd.errors.EmptyDataError:
        errors.append("Features file is empty.")
    except (pd.errors.ParserError, ValueError):
        errors.append(
            "Features file contains malformed CSV formatting (e.g. unquoted fields containing commas, " 
            "mismatched quotes, etc)."
        )
    except Exception as e:
        errors.append(f"Failed to read features file: {e}")
    else:
        # Validate column structure first.
        if header_errors := check_feature_columns(pred.columns):
            errors.append(header_errors)
        
        # Next, validate file contents.
        else:
            # truth = pd.read_csv(
            #     gt_file,
            # ).set_index(ID_COLUMN)
            if pred.isna().all().all():  # will return True if df has 0 rows OR all cells are NaN
                errors.append("Features file only contains NaN values.")
            else:
                errors.append(check_nan_columns(pred))
    
    # Remove any empty strings from the list before return.
    return [err for err in errors if err] 


def main(
    predictions_file: Annotated[
        str,
        typer.Option(
            "-p",
            "--predictions_file",
            help="Path to the prediction file.",
        ),
    ],
    # groundtruth_file: Annotated[
    #     str,
    #     typer.Option(
    #         "-g",
    #         "--groundtruth_file",
    #         help="Path to the groundtruth file.",
    #     ),
    # ],
    output_file: Annotated[
        str,
        typer.Option(
            "-o",
            "--output_file",
            help="Path to save the results JSON file.",
        ),
    ] = "results.json",
):
    """Validates the predictions file in preparation for evaluation."""

    errors = validate(
        # gt_file=groundtruth_file,
        pred_file=predictions_file,
    )

    invalid_reasons = "\n".join(errors)
    status = "INVALID" if invalid_reasons else "VALIDATED"

    # Truncate validation errors if >500 (char limit for sending Synapse email)
    if len(invalid_reasons) > 500:
        invalid_reasons = invalid_reasons[:496] + "..."
    res = {
        "submission_status": status,
        "submission_errors": invalid_reasons,
    }

    with open(output_file, "w", encoding="utf-8") as out:
        out.write(json.dumps(res))
    print(status)


if __name__ == "__main__":
    # Prevent replacing underscore with dashes in CLI names.
    typer.main.get_command_name = lambda name: name
    typer.run(main)
