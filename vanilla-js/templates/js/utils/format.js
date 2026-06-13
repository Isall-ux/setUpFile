export function formatDate(dateStr) {
  var d = new Date(dateStr)
  return d.toLocaleDateString()
}

export function formatNumber(n) {
  return new Intl.NumberFormat().format(n)
}

export function truncate(str, max) {
  if (max === void 0) max = 100
  if (str.length <= max) return str
  return str.slice(0, max).trimEnd() + '...'
}
