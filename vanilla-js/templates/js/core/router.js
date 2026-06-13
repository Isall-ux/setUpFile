import { getHashPath } from '../utils/url.js'

// Route table
// Import pages and add them here:
// import { Home } from '../../features/home/home.js'

const routes = {
  // '/': Home,
}

export function listen() {
  window.addEventListener('hashchange', render)
  render()
}

export function render() {
  const path = getHashPath()
  const page = routes[path]

  const main = document.getElementById('main')
  if (!main) return

  if (page) {
    main.innerHTML = ''
    page(main)
  } else {
    main.innerHTML = '<div class="error"><h2>404</h2><p>Page not found: ' + path + '</p></div>'
  }
}
