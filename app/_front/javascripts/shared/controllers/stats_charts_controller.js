import { Controller } from "stimulus"
import { percentageStatsCharts } from '../percentage_column_chart'
import { simpleColumnCharts } from '../simple_column_charts'

export default class extends Controller {
  static targets = ['graph']

  connect() {
    const chart = this.graphTarget;
    const container = chart.id;
    const type = chart.dataset.type;
    const months = JSON.parse(chart.dataset.months);
    const maxValue = chart.dataset.maxValue;
    const series = JSON.parse(chart.dataset.series);
    const colors = JSON.parse(chart.dataset.colors);
    const format = JSON.parse(chart.dataset.format);
    const subtitle = JSON.parse(chart.dataset.subtitle);
    if (type === 'percentage-column-chart') {
      percentageStatsCharts(container, months, maxValue, series, colors, format, subtitle);
    } else {
      simpleColumnCharts(container, months, maxValue, series, colors, format, subtitle);
    }
  }
}
