#!/usr/bin/env python

"""Validation script for digital pen features extraction submissions.

Validation checks include:
- All expected columns are present in the generated CSV file, where:
    * `filename` contains strings
    * `CenterPoint` contains strings, written as a x-y coordinate like: [(x, y)] or [(x.x, y.y)]
    * All other columns contain numbers/floats
- File is not empty
- No NaN values in any of the columns
"""

import argparse
import csv
import json
import re

import pandas as pd
import typer
from typing_extensions import Annotated

PREDICTION_COLS = {
    "filename": str,
    "CenterPoint": str,
    "Circularity": float,
    "RadiusRatio": float,
    "RemovedPoints": float,
    "Radius": float,
    "CenterDeviation": float,
    "HandsAngle": float,
    "DensityRatio": float,
    "BBRatio": float,
    "LengthRatio": float,
    "IntersectDistance": float,
    "NumComponents": float,
    "DigitRadiusMean": float,
    "DigitRadiusStd": float,
    "DigitAngleMean": float,
    "DigitAngleStd": float,
    "DigitAreaMean": float,
    "DigitAreaStd": float,
    "ExtraDigits": float,
    "MissingDigits": float,
    "LeftoverInk": float,
    "PenPressure": float
}


def check_nan_columns(df: pd.DataFrame) -> str:
    """Validates that columns do not contain NaN values."""
    error = ""
    if cols_with_nan := df.columns[df.isna().any()].tolist():
        error = f"Found NaN values in the following columns: {cols_with_nan}."
    return error


def check_invalid_xy_coordinates(pred_col: pd.Series) -> str:
    """
    Validates that the value is a x-y coordinate written as: [(x, y)] or [(x.x, y.y)]
    """
    error = ""

    # Account for spaces around commas and inside brackets/parentheses.
    pattern = r"^\[\s*\(\s*[-]?\d*\.?\d+\s*,\s*[-]?\d*\.?\d+\s*\)\s*\]$"

    # Identify entries that fail the regex pattern match
    invalid_mask = ~pred_col.astype(str).str.match(pattern, na=False)
    num_invalid = invalid_mask.sum()
    if num_invalid > 0:
        error = (
            f"Found {num_invalid} invalid coordinate(s) in '{pred_col.name}'. "
            f"Expected format is '[(x, y)]' or '[(x.x, y.y)]'"
        )
    return error


def validate(pred_file: str) -> list[str] | filter:
    errors = []

    # Check for expected columns.
    file_cols = set(pd.read_csv(pred_file, nrows=0).columns)
    expected_cols = set(PREDICTION_COLS.keys())
    missing_cols = expected_cols - file_cols
    if missing_cols:
        errors.append(
            f"Features file is missing the following required columns: {missing_cols}."
        )

    # Otherwise, check the contents of the predictions file.
    else:
        # truth = pd.read_csv(
        #     gt_file,
        #     usecols=GROUNDTRUTH_COLS,
        #     dtype=GROUNDTRUTH_COLS,
        # )
        pred = pd.read_csv(
            pred_file,
            usecols=PREDICTION_COLS,
            dtype=PREDICTION_COLS,
            float_precision="round_trip",
        )
        if pred.isna().all().all():
            errors.append("Features file contains no data.")
        else:
            errors.append(check_nan_columns(pred))
            errors.append(check_invalid_xy_coordinates(pred["CenterPoint"]))
    # Remove any empty strings from the list before return.
    return filter(None, errors)


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
