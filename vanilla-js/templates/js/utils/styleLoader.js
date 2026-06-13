export function injectStyle(path) {
  const fullPath = window.BASE + path
  const existing = document.querySelector('link[data-href="' + fullPath + '"]')
  if (existing) return existing

  const link = document.createElement('link')
  link.rel = 'stylesheet'
  link.href = fullPath
  link.setAttribute('data-href', fullPath)
  document.head.appendChild(link)
  return link
}
