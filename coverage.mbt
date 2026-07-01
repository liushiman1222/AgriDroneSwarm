///|
/// Coverage module for AgriDroneSwarm.
///
/// This module provides simple field coverage estimation,
/// overlap checking, missing-area risk, and coverage quality helpers.

///|
/// Clamp percentage into 0..100.
pub fn clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Estimate covered area by flight strips.
pub fn estimate_covered_area(strip_count: Int, strip_length: Int, scan_width: Int) -> Int {
  let safe_count = if strip_count < 0 { 0 } else { strip_count }
  let safe_length = if strip_length < 0 { 0 } else { strip_length }
  let safe_width = if scan_width < 0 { 0 } else { scan_width }
  safe_count * safe_length * safe_width
}

///|
/// Estimate coverage percent.
pub fn coverage_percent(covered_area: Int, field_area: Int) -> Int {
  if field_area <= 0 {
    0
  } else {
    clamp_percent(covered_area * 100 / field_area)
  }
}

///|
/// Convert coverage percent to readable level.
pub fn coverage_level_name(percent: Int) -> String {
  let safe_percent = clamp_percent(percent)
  if safe_percent >= 95 {
    "complete"
  } else if safe_percent >= 85 {
    "good"
  } else if safe_percent >= 70 {
    "partial"
  } else {
    "insufficient"
  }
}

///|
/// Estimate overlap percent from spacing and scan width.
pub fn overlap_percent(scan_width: Int, line_spacing: Int) -> Int {
  if scan_width <= 0 {
    0
  } else if line_spacing <= 0 {
    100
  } else if line_spacing >= scan_width {
    0
  } else {
    clamp_percent((scan_width - line_spacing) * 100 / scan_width)
  }
}

///|
/// Convert overlap percent to readable level.
pub fn overlap_level_name(percent: Int) -> String {
  let safe_percent = clamp_percent(percent)
  if safe_percent >= 50 {
    "excessive"
  } else if safe_percent >= 20 {
    "high"
  } else if safe_percent >= 8 {
    "normal"
  } else {
    "low"
  }
}

///|
/// Check whether overlap is acceptable.
pub fn overlap_acceptable(percent: Int) -> Bool {
  let safe_percent = clamp_percent(percent)
  safe_percent >= 8 && safe_percent <= 35
}

///|
/// Estimate missing area.
pub fn missing_area(field_area: Int, covered_area: Int) -> Int {
  let safe_field = if field_area < 0 { 0 } else { field_area }
  let safe_covered = if covered_area < 0 { 0 } else { covered_area }
  if safe_covered >= safe_field {
    0
  } else {
    safe_field - safe_covered
  }
}

///|
/// Estimate missing percent.
pub fn missing_percent(field_area: Int, covered_area: Int) -> Int {
  if field_area <= 0 {
    100
  } else {
    clamp_percent(missing_area(field_area, covered_area) * 100 / field_area)
  }
}

///|
/// Convert missing percent to readable level.
pub fn missing_level_name(percent: Int) -> String {
  let safe_percent = clamp_percent(percent)
  if safe_percent >= 30 {
    "severe"
  } else if safe_percent >= 15 {
    "medium"
  } else if safe_percent >= 5 {
    "minor"
  } else {
    "none"
  }
}

///|
/// Estimate scan density.
pub fn scan_density(sample_count: Int, field_area: Int) -> Int {
  if sample_count <= 0 || field_area <= 0 {
    0
  } else {
    sample_count * 1000 / field_area
  }
}

///|
/// Convert scan density to readable level.
pub fn scan_density_name(density: Int) -> String {
  if density >= 20 {
    "dense"
  } else if density >= 10 {
    "normal"
  } else if density >= 4 {
    "sparse"
  } else {
    "very-sparse"
  }
}

///|
/// Estimate coverage quality score.
pub fn coverage_quality_score(
  coverage: Int,
  overlap: Int,
  missing: Int,
  sensor_quality: Int
) -> Int {
  let c = clamp_percent(coverage)
  let o = clamp_percent(overlap)
  let m = clamp_percent(missing)
  let s = clamp_sensor_quality(sensor_quality)

  let overlap_score = if o >= 8 && o <= 35 {
    100
  } else if o < 8 {
    70
  } else if o <= 50 {
    60
  } else {
    35
  }

  let missing_score = 100 - m
  clamp_percent(c * 4 / 10 + overlap_score * 2 / 10 + missing_score * 2 / 10 + s * 2 / 10)
}

///|
/// Convert coverage quality score to readable level.
pub fn coverage_quality_name(score: Int) -> String {
  let safe_score = clamp_percent(score)
  if safe_score >= 90 {
    "excellent"
  } else if safe_score >= 75 {
    "good"
  } else if safe_score >= 55 {
    "acceptable"
  } else {
    "poor"
  }
}

///|
/// Check whether a field needs another coverage pass.
pub fn needs_recoverage(
  coverage: Int,
  overlap: Int,
  missing: Int,
  sensor_quality: Int
) -> Bool {
  let quality = coverage_quality_score(coverage, overlap, missing, sensor_quality)
  quality < 75 || coverage < 85 || missing > 15 || !overlap_acceptable(overlap)
}

///|
/// Estimate extra flight strips needed for missing area.
pub fn extra_strips_needed(missing_area_value: Int, strip_length: Int, scan_width: Int) -> Int {
  let strip_area = strip_length * scan_width
  if missing_area_value <= 0 || strip_area <= 0 {
    0
  } else {
    (missing_area_value + strip_area - 1) / strip_area
  }
}

///|
/// Check whether coverage is valid for mapping.
pub fn mapping_coverage_valid(
  coverage: Int,
  overlap: Int,
  sensor_quality: Int
) -> Bool {
  coverage >= 90 && overlap_acceptable(overlap) && sensor_usable(sensor_quality)
}

///|
/// Check whether coverage is valid for spraying.
pub fn spraying_coverage_valid(
  coverage: Int,
  overlap: Int
) -> Bool {
  coverage >= 85 && overlap <= 40
}

///|
/// Check whether coverage is valid for inspection.
pub fn inspection_coverage_valid(
  coverage: Int,
  sensor_quality: Int
) -> Bool {
  coverage >= 80 && sensor_usable(sensor_quality)
}

///|
/// Check mission coverage validity.
pub fn mission_coverage_valid(
  mission_kind: Int,
  coverage: Int,
  overlap: Int,
  sensor_quality: Int
) -> Bool {
  if mission_kind == mission_type_mapping() {
    mapping_coverage_valid(coverage, overlap, sensor_quality)
  } else if mission_kind == mission_type_spraying() {
    spraying_coverage_valid(coverage, overlap)
  } else if mission_kind == mission_type_inspection() {
    inspection_coverage_valid(coverage, sensor_quality)
  } else {
    coverage >= 75
  }
}

///|
/// Coverage module demo.
pub fn coverage_summary() -> Unit {
  let field_area = 12000
  let covered = estimate_covered_area(8, 300, 5)
  let coverage = coverage_percent(covered, field_area)
  let overlap = overlap_percent(5, 4)
  let missing = missing_percent(field_area, covered)
  let quality = coverage_quality_score(coverage, overlap, missing, 82)

  println("Coverage module:")
  println("- Coverage rule: covered area compared with total field area")
  println("- Overlap rule: scan width and line spacing decide repeated coverage")
  println("- Quality rule: coverage, overlap, missing area, and sensor quality")
  println("- Example coverage:")
  println(coverage_level_name(coverage))
  println("- Example overlap:")
  println(overlap_level_name(overlap))
  println("- Example missing level:")
  println(missing_level_name(missing))
  println("- Example quality:")
  println(coverage_quality_name(quality))
}
