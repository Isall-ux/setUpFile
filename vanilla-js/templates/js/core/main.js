import { listen } from './router.js'

// Layout components — uncomment as you create them:
// import { renderNavbar } from '../../components/layout/navbar/navbar.js'
// import { renderTopBar } from '../../components/layout/top-bar/top-bar.js'
// import { renderBottomBar } from '../../components/layout/bottom-bar/bottom-bar.js'
// import { renderFooter } from '../../components/layout/footer/footer.js'

;(function main() {
  const hash = window.location.hash
  window.location.hash = ''

  // Mount layout components
  // renderNavbar(document.getElementById('navbar'))
  // renderTopBar(document.getElementById('top-bar'))
  // renderBottomBar(document.getElementById('bottom-bar'))
  // renderFooter(document.getElementById('footer'))

  window.location.hash = hash
  listen()
})()
