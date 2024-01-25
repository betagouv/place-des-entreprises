export function simpleColumnCharts (container, months, max_value, series, colors, format, subtitle) {
  Highcharts.chart(container, {
    colors: colors,
    chart: {
      type: 'column'
    },
    title: {
      text: null
    },
    subtitle: {
      text: subtitle,
      align: 'left',
      y: 10
    },
    credits: {
      enabled: false
    },
    plotOptions: {
      series: {
        animation: false
      },
      column: {
        stacking: 'normal'
      }
    },
    tooltip: {
      pointFormat: format
    },
    xAxis: {
      categories: months,
      tickInterval: 1,
      min: 0,
      max: months.length - 1
    },
    yAxis: {
      title: null,
      max: max_value
    },
    legend: {
      enabled: true,
      itemHiddenStyle: {
        color: '#565656'
      },
      itemMarginTop: 10,
      itemMarginBottom: 10
    },
    series: series
  })
}

