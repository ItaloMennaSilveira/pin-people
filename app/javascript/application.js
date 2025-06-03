// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "chart.js"
window.Chart = Chart
import "chartjs-plugin-datalabels";
Chart.register(ChartDataLabels);
