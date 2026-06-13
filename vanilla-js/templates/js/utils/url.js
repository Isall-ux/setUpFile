// Never write window.location.hash directly outside this file

export function getHashPath() {
  const hash = window.location.hash.slice(1) || '/'
  const qIndex = hash.indexOf('?')
  return qIndex === -1 ? hash : hash.slice(0, qIndex)
}

export function getHashParams() {
  const hash = window.location.hash.slice(1)
  const qIndex = hash.indexOf('?')
  const qs = qIndex === -1 ? '' : hash.slice(qIndex)
  return new URLSearchParams(qs)
}

export function navigateTo(path) {
  window.location.hash = path
}

export function asset(path) {
  return window.BASE + '/' + path.replace(/^\//, '')
}
