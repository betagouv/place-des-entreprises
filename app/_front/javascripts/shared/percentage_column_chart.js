export function percentageStatsCharts (container, months, max_value, series, colors, format, subtitle) {
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
    xAxis: {
      categories: months,
      tickInterval: 1,
      min: 0,
      max: months.length - 1
    },
    yAxis: {
      min: 0,
      title: {
        text: null
      },
      labels: {
        format: '{value} %'
      }
    },
    tooltip: {
      pointFormat: format,
    },
    plotOptions: {
      column: {
        stacking: 'percent'
      }
    },
    legend: {
      itemHiddenStyle: {
        color: '#565656'
      },
      itemMarginTop: 10,
      itemMarginBottom: 10
    },
    series: series
  });
}
