// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import Chart from "chart.js"
import "chartjs-adapter-date-fns"
window.Chart = Chart
import "chartkick"

// Enable Turbo progress bar
import { Turbo } from "@hotwired/turbo-rails"
Turbo.setProgressBarDelay(200)

// Fix CSRF tokens in dynamically inserted forms (Turbo Stream broadcasts render without request context)
function fixCsrfTokens() {
  const token = document.querySelector('meta[name="csrf-token"]')?.content
  if (!token) return
  document.querySelectorAll('form input[name="authenticity_token"]').forEach(input => {
    input.value = token
  })
}

// Run after any Turbo Stream renders
const observer = new MutationObserver(() => fixCsrfTokens())
observer.observe(document.body, { childList: true, subtree: true })

// Configure Turbo for better UX
document.addEventListener("turbo:load", () => {
  // Auto-focus first input on page load
  const firstInput = document.querySelector('input:not([type="hidden"]):not([readonly])')
  if (firstInput) {
    firstInput.focus()
  }
})
