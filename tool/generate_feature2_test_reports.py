from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    KeepTogether,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)


OUTPUT_DIR = Path(__file__).resolve().parents[1] / "output" / "pdf"

NAVY = colors.HexColor("#10233F")
BLUE = colors.HexColor("#2563EB")
PALE_BLUE = colors.HexColor("#EFF6FF")
GREEN = colors.HexColor("#059669")
PALE_GREEN = colors.HexColor("#ECFDF5")
ORANGE = colors.HexColor("#EA580C")
PALE_ORANGE = colors.HexColor("#FFF7ED")
RED = colors.HexColor("#DC2626")
PALE_RED = colors.HexColor("#FEF2F2")
SLATE = colors.HexColor("#64748B")
LIGHT_BORDER = colors.HexColor("#D8E1EC")
ROW_ALT = colors.HexColor("#F8FAFC")


@dataclass(frozen=True)
class LabRow:
    name: str
    value: str
    reference: str
    unit: str
    flag: str


@dataclass(frozen=True)
class ReportDefinition:
    filename: str
    title: str
    report_id: str
    report_date: str
    panel: str
    expected: str
    rows: tuple[LabRow, ...]


REPORTS = (
    ReportDefinition(
        filename="VistaCortex_Trend_01_Baseline_High_2026-01-15.pdf",
        title="Comprehensive Metabolic and Lipid Panel",
        report_id="VC-TREND-001",
        report_date="15 Jan 2026",
        panel="Trend baseline - abnormal",
        expected=(
            "Expected app result: multiple Borderline High and Critical High values. "
            "Use as the first point in glucose and lipid trends."
        ),
        rows=(
            LabRow("Hemoglobin", "13.4", "12.0 - 16.0", "g/dL", "Normal"),
            LabRow("Hematocrit", "40.1", "36.0 - 46.0", "%", "Normal"),
            LabRow("RBC Count", "4.55", "4.0 - 5.2", "million/uL", "Normal"),
            LabRow("WBC Count", "7.8", "4.0 - 11.0", "thousand/uL", "Normal"),
            LabRow("Platelet Count", "282", "150 - 450", "thousand/uL", "Normal"),
            LabRow("Fasting Glucose", "156", "70 - 99", "mg/dL", "Critical High"),
            LabRow("HbA1c", "7.8", "4.0 - 5.6", "%", "Critical High"),
            LabRow("Total Cholesterol", "262", "125 - 200", "mg/dL", "Critical High"),
            LabRow("LDL Cholesterol", "176", "0 - 100", "mg/dL", "Critical High"),
            LabRow("HDL Cholesterol", "38", "40 - 100", "mg/dL", "Borderline Low"),
            LabRow("Triglycerides", "242", "0 - 150", "mg/dL", "Critical High"),
            LabRow("Creatinine", "0.92", "0.60 - 1.10", "mg/dL", "Normal"),
            LabRow("eGFR", "94", "60 - 150", "mL/min/1.73m2", "Normal"),
            LabRow("Sodium", "140", "136 - 145", "mmol/L", "Normal"),
            LabRow("Potassium", "4.3", "3.5 - 5.1", "mmol/L", "Normal"),
        ),
    ),
    ReportDefinition(
        filename="VistaCortex_Trend_02_Improving_2026-04-15.pdf",
        title="Metabolic and Lipid Follow-up",
        report_id="VC-TREND-002",
        report_date="15 Apr 2026",
        panel="Trend follow-up - improving",
        expected=(
            "Expected app result: values remain outside range but trend downward from "
            "the January baseline."
        ),
        rows=(
            LabRow("Hemoglobin", "13.6", "12.0 - 16.0", "g/dL", "Normal"),
            LabRow("Hematocrit", "40.8", "36.0 - 46.0", "%", "Normal"),
            LabRow("RBC Count", "4.60", "4.0 - 5.2", "million/uL", "Normal"),
            LabRow("WBC Count", "7.5", "4.0 - 11.0", "thousand/uL", "Normal"),
            LabRow("Platelet Count", "276", "150 - 450", "thousand/uL", "Normal"),
            LabRow("Fasting Glucose", "124", "70 - 99", "mg/dL", "Borderline High"),
            LabRow("HbA1c", "6.5", "4.0 - 5.6", "%", "Borderline High"),
            LabRow("Total Cholesterol", "224", "125 - 200", "mg/dL", "Borderline High"),
            LabRow("LDL Cholesterol", "125", "0 - 100", "mg/dL", "Borderline High"),
            LabRow("HDL Cholesterol", "44", "40 - 100", "mg/dL", "Normal"),
            LabRow("Triglycerides", "175", "0 - 150", "mg/dL", "Borderline High"),
            LabRow("Creatinine", "0.89", "0.60 - 1.10", "mg/dL", "Normal"),
            LabRow("eGFR", "98", "60 - 150", "mL/min/1.73m2", "Normal"),
            LabRow("Sodium", "139", "136 - 145", "mmol/L", "Normal"),
            LabRow("Potassium", "4.1", "3.5 - 5.1", "mmol/L", "Normal"),
        ),
    ),
    ReportDefinition(
        filename="VistaCortex_Trend_03_Normal_2026-07-15.pdf",
        title="Metabolic and Lipid Follow-up",
        report_id="VC-TREND-003",
        report_date="15 Jul 2026",
        panel="Trend follow-up - in range",
        expected=(
            "Expected app result: all extracted values are in range. Trendlines should "
            "show continued improvement from January and April."
        ),
        rows=(
            LabRow("Hemoglobin", "13.8", "12.0 - 16.0", "g/dL", "Normal"),
            LabRow("Hematocrit", "41.3", "36.0 - 46.0", "%", "Normal"),
            LabRow("RBC Count", "4.66", "4.0 - 5.2", "million/uL", "Normal"),
            LabRow("WBC Count", "7.2", "4.0 - 11.0", "thousand/uL", "Normal"),
            LabRow("Platelet Count", "270", "150 - 450", "thousand/uL", "Normal"),
            LabRow("Fasting Glucose", "92", "70 - 99", "mg/dL", "Normal"),
            LabRow("HbA1c", "5.4", "4.0 - 5.6", "%", "Normal"),
            LabRow("Total Cholesterol", "182", "125 - 200", "mg/dL", "Normal"),
            LabRow("LDL Cholesterol", "92", "0 - 100", "mg/dL", "Normal"),
            LabRow("HDL Cholesterol", "55", "40 - 100", "mg/dL", "Normal"),
            LabRow("Triglycerides", "110", "0 - 150", "mg/dL", "Normal"),
            LabRow("Creatinine", "0.84", "0.60 - 1.10", "mg/dL", "Normal"),
            LabRow("eGFR", "102", "60 - 150", "mL/min/1.73m2", "Normal"),
            LabRow("Sodium", "141", "136 - 145", "mmol/L", "Normal"),
            LabRow("Potassium", "4.0", "3.5 - 5.1", "mmol/L", "Normal"),
        ),
    ),
    ReportDefinition(
        filename="VistaCortex_Critical_CBC_Kidney_2026-08-20.pdf",
        title="Urgent CBC, Renal and Electrolyte Panel",
        report_id="VC-CRITICAL-004",
        report_date="20 Aug 2026",
        panel="Critical-value classification",
        expected=(
            "Expected app result: multiple Critical Low and Critical High labels, red "
            "status styling, urgent plain-language review guidance, and kidney-aware diet cautions."
        ),
        rows=(
            LabRow("Hemoglobin", "7.2", "12.0 - 16.0", "g/dL", "Critical Low"),
            LabRow("Hematocrit", "24.0", "36.0 - 46.0", "%", "Critical Low"),
            LabRow("RBC Count", "2.8", "4.0 - 5.2", "million/uL", "Borderline Low"),
            LabRow("WBC Count", "14.8", "4.0 - 11.0", "thousand/uL", "Critical High"),
            LabRow("Platelet Count", "70", "150 - 450", "thousand/uL", "Critical Low"),
            LabRow("Ferritin", "10", "30 - 300", "ng/mL", "Critical Low"),
            LabRow("Fasting Glucose", "168", "70 - 99", "mg/dL", "Critical High"),
            LabRow("Creatinine", "2.4", "0.60 - 1.10", "mg/dL", "Critical High"),
            LabRow("eGFR", "28", "60 - 150", "mL/min/1.73m2", "Critical Low"),
            LabRow("Sodium", "90", "136 - 145", "mmol/L", "Critical Low"),
            LabRow("Potassium", "6.8", "3.5 - 5.1", "mmol/L", "Critical High"),
            LabRow("ALT", "65", "7 - 56", "U/L", "Borderline High"),
            LabRow("AST", "62", "10 - 40", "U/L", "Critical High"),
            LabRow("TSH", "7.1", "0.4 - 4.0", "mIU/L", "Critical High"),
            LabRow("Vitamin D", "16", "30 - 100", "ng/mL", "Critical Low"),
            LabRow("Vitamin B12", "145", "200 - 900", "pg/mL", "Borderline Low"),
        ),
    ),
)


def styles():
    base = getSampleStyleSheet()
    return {
        "title": ParagraphStyle(
            "ReportTitle",
            parent=base["Title"],
            fontName="Helvetica-Bold",
            fontSize=18,
            leading=22,
            textColor=NAVY,
            alignment=TA_LEFT,
            spaceAfter=3 * mm,
        ),
        "subtitle": ParagraphStyle(
            "Subtitle",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=9,
            leading=12,
            textColor=SLATE,
        ),
        "section": ParagraphStyle(
            "Section",
            parent=base["Heading2"],
            fontName="Helvetica-Bold",
            fontSize=11,
            leading=14,
            textColor=NAVY,
            spaceAfter=2 * mm,
        ),
        "small": ParagraphStyle(
            "Small",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=8,
            leading=11,
            textColor=SLATE,
        ),
        "expected": ParagraphStyle(
            "Expected",
            parent=base["Normal"],
            fontName="Helvetica",
            fontSize=8.5,
            leading=12,
            textColor=NAVY,
        ),
        "center": ParagraphStyle(
            "Center",
            parent=base["Normal"],
            fontName="Helvetica-Bold",
            fontSize=9,
            leading=12,
            alignment=TA_CENTER,
            textColor=NAVY,
        ),
    }


def flag_colors(flag: str):
    if flag == "Normal":
        return PALE_GREEN, GREEN
    if flag.startswith("Critical"):
        return PALE_RED, RED
    return PALE_ORANGE, ORANGE


def header_block(report: ReportDefinition, style_map):
    metadata = Table(
        [
            ["Patient", "Alex Morgan (synthetic)", "Report ID", report.report_id],
            ["Collected", report.report_date, "Reported", report.report_date],
            ["Laboratory", "VistaCortex QA Laboratory", "Panel", report.panel],
        ],
        colWidths=[24 * mm, 59 * mm, 24 * mm, 60 * mm],
        rowHeights=[8 * mm, 8 * mm, 8 * mm],
    )
    metadata.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), PALE_BLUE),
                ("BOX", (0, 0), (-1, -1), 0.7, colors.HexColor("#BFDBFE")),
                ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#DBEAFE")),
                ("FONTNAME", (0, 0), (-1, -1), "Helvetica"),
                ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
                ("FONTNAME", (2, 0), (2, -1), "Helvetica-Bold"),
                ("TEXTCOLOR", (0, 0), (-1, -1), NAVY),
                ("FONTSIZE", (0, 0), (-1, -1), 8.5),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
            ]
        )
    )
    return [
        Paragraph("VISTACORTEX QA LABORATORY", style_map["center"]),
        Spacer(1, 2 * mm),
        Paragraph(report.title, style_map["title"]),
        Paragraph(
            "Synthetic test document - not a real patient record and not for clinical use",
            style_map["subtitle"],
        ),
        Spacer(1, 4 * mm),
        metadata,
        Spacer(1, 5 * mm),
    ]


def results_table(report: ReportDefinition):
    data = [["Test", "Result", "Reference range", "Unit", "Status"]]
    data.extend(
        [[row.name, row.value, row.reference, row.unit, row.flag] for row in report.rows]
    )
    table = Table(
        data,
        repeatRows=1,
        colWidths=[47 * mm, 23 * mm, 35 * mm, 32 * mm, 30 * mm],
        rowHeights=[8 * mm] + [7.5 * mm] * len(report.rows),
    )
    commands = [
        ("BACKGROUND", (0, 0), (-1, 0), NAVY),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ("FONTSIZE", (0, 0), (-1, 0), 8),
        ("ALIGN", (1, 1), (2, -1), "CENTER"),
        ("ALIGN", (4, 1), (4, -1), "CENTER"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("FONTNAME", (0, 1), (-1, -1), "Helvetica"),
        ("FONTNAME", (0, 1), (0, -1), "Helvetica-Bold"),
        ("FONTSIZE", (0, 1), (-1, -1), 8),
        ("TEXTCOLOR", (0, 1), (-1, -1), NAVY),
        ("GRID", (0, 0), (-1, -1), 0.4, LIGHT_BORDER),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
    ]
    for index, row in enumerate(report.rows, start=1):
        if index % 2 == 0:
            commands.append(("BACKGROUND", (0, index), (3, index), ROW_ALT))
        background, foreground = flag_colors(row.flag)
        commands.extend(
            [
                ("BACKGROUND", (4, index), (4, index), background),
                ("TEXTCOLOR", (4, index), (4, index), foreground),
                ("FONTNAME", (4, index), (4, index), "Helvetica-Bold"),
            ]
        )
    table.setStyle(TableStyle(commands))
    return table


def footer(canvas, document):
    canvas.saveState()
    canvas.setStrokeColor(LIGHT_BORDER)
    canvas.line(20 * mm, 14 * mm, A4[0] - 20 * mm, 14 * mm)
    canvas.setFont("Helvetica", 7)
    canvas.setFillColor(SLATE)
    canvas.drawString(20 * mm, 9 * mm, "VistaCortex synthetic QA report")
    canvas.drawRightString(
        A4[0] - 20 * mm,
        9 * mm,
        f"Page {document.page}",
    )
    canvas.restoreState()


def build_lab_report(report: ReportDefinition):
    style_map = styles()
    output_path = OUTPUT_DIR / report.filename
    document = SimpleDocTemplate(
        str(output_path),
        pagesize=A4,
        rightMargin=20 * mm,
        leftMargin=20 * mm,
        topMargin=15 * mm,
        bottomMargin=19 * mm,
        title=report.title,
        author="VistaCortex QA",
        subject="Synthetic Feature 2 OCR and trend testing",
    )
    expected_box = Table(
        [[Paragraph(f"<b>QA scenario:</b> {report.expected}", style_map["expected"])]],
        colWidths=[167 * mm],
    )
    expected_box.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), PALE_BLUE),
                ("BOX", (0, 0), (-1, -1), 0.7, colors.HexColor("#93C5FD")),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 8),
                ("TOPPADDING", (0, 0), (-1, -1), 7),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    story = header_block(report, style_map)
    story.extend(
        [
            Paragraph("Laboratory results", style_map["section"]),
            results_table(report),
            Spacer(1, 4 * mm),
            KeepTogether(expected_box),
            Spacer(1, 3 * mm),
            Paragraph(
                "Reference ranges are synthetic and included only to test extraction, "
                "classification, analysis, diet guidance, and historical trends.",
                style_map["small"],
            ),
        ]
    )
    document.build(story, onFirstPage=footer, onLaterPages=footer)
    return output_path


def build_no_biomarker_report():
    style_map = styles()
    output_path = OUTPUT_DIR / "VistaCortex_No_Biomarkers_Imaging_Note_2026-09-01.pdf"
    document = SimpleDocTemplate(
        str(output_path),
        pagesize=A4,
        rightMargin=22 * mm,
        leftMargin=22 * mm,
        topMargin=18 * mm,
        bottomMargin=19 * mm,
        title="Imaging Observation Note",
        author="VistaCortex QA",
        subject="Synthetic no-biomarker extraction test",
    )
    info = Table(
        [
            ["Patient", "Alex Morgan (synthetic)"],
            ["Report ID", "VC-NOVALUES-005"],
            ["Report date", "01 Sep 2026"],
            ["Study", "Chest imaging observation"],
        ],
        colWidths=[36 * mm, 116 * mm],
        rowHeights=[9 * mm] * 4,
    )
    info.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), PALE_BLUE),
                ("BOX", (0, 0), (-1, -1), 0.7, colors.HexColor("#BFDBFE")),
                ("INNERGRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#DBEAFE")),
                ("FONTNAME", (0, 0), (0, -1), "Helvetica-Bold"),
                ("FONTNAME", (1, 0), (1, -1), "Helvetica"),
                ("FONTSIZE", (0, 0), (-1, -1), 9),
                ("TEXTCOLOR", (0, 0), (-1, -1), NAVY),
                ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                ("LEFTPADDING", (0, 0), (-1, -1), 7),
            ]
        )
    )
    body_style = ParagraphStyle(
        "ImagingBody",
        parent=style_map["small"],
        fontSize=10,
        leading=16,
        textColor=NAVY,
        spaceAfter=3 * mm,
    )
    story = [
        Paragraph("VISTACORTEX QA LABORATORY", style_map["center"]),
        Spacer(1, 3 * mm),
        Paragraph("Imaging Observation Note", style_map["title"]),
        Paragraph(
            "Synthetic test document - not a real patient record and not for clinical use",
            style_map["subtitle"],
        ),
        Spacer(1, 5 * mm),
        info,
        Spacer(1, 8 * mm),
        Paragraph("Observation", style_map["section"]),
        Paragraph(
            "The study is technically adequate. The visualized lung fields are clear. "
            "No focal air-space opacity, pleural fluid collection, or acute osseous "
            "abnormality is identified.",
            body_style,
        ),
        Paragraph("Impression", style_map["section"]),
        Paragraph(
            "No acute cardiopulmonary abnormality is identified on this synthetic image note.",
            body_style,
        ),
        Spacer(1, 8 * mm),
        Table(
            [[Paragraph(
                "<b>QA scenario:</b> This document intentionally contains no supported "
                "structured laboratory biomarkers. The app should store the file, display "
                "No values found, avoid creating a diet plan, and allow analysis retry.",
                style_map["expected"],
            )]],
            colWidths=[152 * mm],
            style=TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, -1), PALE_ORANGE),
                    ("BOX", (0, 0), (-1, -1), 0.7, colors.HexColor("#FDBA74")),
                    ("LEFTPADDING", (0, 0), (-1, -1), 9),
                    ("RIGHTPADDING", (0, 0), (-1, -1), 9),
                    ("TOPPADDING", (0, 0), (-1, -1), 9),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 9),
                ]
            ),
        ),
    ]
    document.build(story, onFirstPage=footer, onLaterPages=footer)
    return output_path


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    outputs = [build_lab_report(report) for report in REPORTS]
    outputs.append(build_no_biomarker_report())
    for output in outputs:
        print(output)


if __name__ == "__main__":
    main()
