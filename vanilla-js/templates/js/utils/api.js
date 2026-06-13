// Do not use fetchData() for external URLs — use raw fetch() instead

export async function fetchData(path) {
  const url = window.BASE + path
  const res = await fetch(url)
  if (!res.ok) throw new Error('HTTP ' + res.status + ': ' + url)
  return res.json()
}
