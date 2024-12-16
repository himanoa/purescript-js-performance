export const _now = () => {
  return performance.now()
}

export const _clearMarks = (name) => () => {
  return performance.clearMarks(name)
}

export const _clearMeasures = (name) => () => {
  return performance.clearMeasures(name)
}

export const _clearResourceTimings = () => {
  return performance.clearResourceTimings()
}

export const _getEntries = () => {
  return performance.getEntries()
}

export const _getEntriesByName = (name) => () => {
  return performance.getEntriesByName(name)
}

export const _getEntriesByType= (type) => () => {
  return performance.getEntriesByType(type)
}

export const _mark= (mark) => (options) => () => {
  return performance.mark(mark, options)
}

export const _measure= (mark) => (optionsOrStartMark) => (endMark) => () => {
  return performance.measure(mark, optionsOrStartMark, endMark)
}

export const _setResourceTimingBufferSize = (maxSize) => () => {
  return performance.setResouceTimingBufferSize(maxsize)
}
