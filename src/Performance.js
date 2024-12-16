export const _now = () => performance.now();

export const _clearMarks = (name) => () => {
  performance.clearMarks(name);
};

export const __clearMarks = () => {
  performance.clearMarks();
};

export const _clearMeasures = (name) => () => {
  performance.clearMeasures(name);
};

export const __clearMeasures = () => {
  performance.clearMeasures();
};

export const _clearResourceTimings = () => () => {
  performance.clearResourceTimings();
};

export const _getEntries = () => performance.getEntries();

export const _getEntriesByName = (name) => () => performance.getEntriesByName(name);

export const _getEntriesByType = (type) => () => performance.getEntriesByType(type);

export const _mark = (name) => (options) => () => performance.mark(name, options);

export const _measure = (name) => (options) => () => performance.measure(name, options);

export const _setResourceTimingBufferSize = (size) => () => {
  performance.setResourceTimingBufferSize(size);
};
