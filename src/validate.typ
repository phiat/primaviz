// validate.typ - Input validation helpers for chart functions

// Validate simple data (labels + values)
#let validate-simple-data(data, chart-name) = {
  assert(type(data) == dictionary or type(data) == array,
    message: chart-name + ": data must be a dictionary or array")
  if type(data) == dictionary {
    assert("labels" in data, message: chart-name + ": data must have 'labels' key")
    assert("values" in data, message: chart-name + ": data must have 'values' key")
    assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
    assert(data.labels.len() == data.values.len(),
      message: chart-name + ": labels (" + str(data.labels.len()) + ") and values (" + str(data.values.len()) + ") must have same length")
  }
}

// Validate multi-series data (labels + series array)
#let validate-series-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("series" in data, message: chart-name + ": data must have 'series' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.series.len() > 0, message: chart-name + ": series must not be empty")
  for (i, s) in data.series.enumerate() {
    assert("name" in s, message: chart-name + ": series[" + str(i) + "] must have 'name' key")
    assert("values" in s, message: chart-name + ": series[" + str(i) + "] must have 'values' key")
    assert(s.values.len() == data.labels.len(),
      message: chart-name + ": series '" + s.name + "' has " + str(s.values.len()) + " values but " + str(data.labels.len()) + " labels")
  }
}

// Validate scatter data (x + y arrays)
#let validate-scatter-data(data, chart-name) = {
  if type(data) == dictionary {
    assert("x" in data, message: chart-name + ": data must have 'x' key")
    assert("y" in data, message: chart-name + ": data must have 'y' key")
    assert(data.x.len() > 0, message: chart-name + ": x values must not be empty")
    assert(data.x.len() == data.y.len(),
      message: chart-name + ": x (" + str(data.x.len()) + ") and y (" + str(data.y.len()) + ") must have same length")
  }
}

// Validate bubble data (x + y + size arrays)
#let validate-bubble-data(data, chart-name) = {
  validate-scatter-data(data, chart-name)
  if type(data) == dictionary {
    assert("size" in data, message: chart-name + ": data must have 'size' key")
    assert(data.size.len() == data.x.len(),
      message: chart-name + ": size (" + str(data.size.len()) + ") must match x/y length (" + str(data.x.len()) + ")")
  }
}

// Validate heatmap data (rows + cols + values 2D array)
#let validate-heatmap-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("rows" in data, message: chart-name + ": data must have 'rows' key")
  assert("cols" in data, message: chart-name + ": data must have 'cols' key")
  assert("values" in data, message: chart-name + ": data must have 'values' key")
  assert(data.rows.len() > 0, message: chart-name + ": rows must not be empty")
  assert(data.cols.len() > 0, message: chart-name + ": cols must not be empty")
  assert(data.values.len() == data.rows.len(),
    message: chart-name + ": values has " + str(data.values.len()) + " rows but " + str(data.rows.len()) + " row labels")
}

// Validate calendar heatmap data
#let validate-calendar-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("dates" in data, message: chart-name + ": data must have 'dates' key")
  assert("values" in data, message: chart-name + ": data must have 'values' key")
  assert(data.dates.len() > 0, message: chart-name + ": dates must not be empty")
  assert(data.dates.len() == data.values.len(),
    message: chart-name + ": dates (" + str(data.dates.len()) + ") and values (" + str(data.values.len()) + ") must have same length")
}

// Validate correlation matrix
#let validate-correlation-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("labels" in data, message: chart-name + ": data must have 'labels' key")
  assert("values" in data, message: chart-name + ": data must have 'values' key")
  assert(data.labels.len() > 0, message: chart-name + ": labels must not be empty")
  assert(data.values.len() == data.labels.len(),
    message: chart-name + ": values must be a square matrix matching labels length")
}

// Validate numeric value (for gauge, progress)
#let validate-number(value, chart-name) = {
  assert(type(value) == int or type(value) == float,
    message: chart-name + ": value must be a number, got " + str(type(value)))
}

// Validate multi-scatter data
#let validate-multi-scatter-data(data, chart-name) = {
  assert(type(data) == dictionary, message: chart-name + ": data must be a dictionary")
  assert("series" in data, message: chart-name + ": data must have 'series' key")
  assert(data.series.len() > 0, message: chart-name + ": series must not be empty")
  for (i, s) in data.series.enumerate() {
    assert("name" in s, message: chart-name + ": series[" + str(i) + "] must have 'name' key")
    assert("points" in s, message: chart-name + ": series[" + str(i) + "] must have 'points' key")
    assert(s.points.len() > 0, message: chart-name + ": series '" + s.name + "' must have at least one point")
  }
}
