export const $ = (sel, ctx) => (ctx || document).querySelector(sel)

export const $$ = (sel, ctx) => [...(ctx || document).querySelectorAll(sel)]

export function createElement(tag, attrs, children) {
  if (attrs === void 0) attrs = {}
  if (children === void 0) children = []

  const el = document.createElement(tag)
  for (var key in attrs) {
    if (!attrs.hasOwnProperty(key)) continue
    var val = attrs[key]
    if (key === 'className') {
      el.className = val
    } else if (key === 'dataset') {
      Object.assign(el.dataset, val)
    } else if (key.startsWith('on')) {
      el.addEventListener(key.slice(2).toLowerCase(), val)
    } else {
      el.setAttribute(key, val)
    }
  }
  for (var i = 0; i < children.length; i++) {
    var child = children[i]
    if (typeof child === 'string') {
      el.appendChild(document.createTextNode(child))
    } else {
      el.appendChild(child)
    }
  }
  return el
}
