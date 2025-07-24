// Chart Hooks for Phoenix LiveView
const ChartHooks = {
  BarChart: {
    mounted() {
      const chartData = JSON.parse(this.el.dataset.chartData);
      
      // Add entrance animation to the container
      this.el.style.opacity = '0';
      this.el.style.transform = 'translateY(20px)';
      
      setTimeout(() => {
        this.el.style.transition = 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)';
        this.el.style.opacity = '1';
        this.el.style.transform = 'translateY(0)';
      }, 100);
      
      const options = {
        series: chartData.series,
        chart: {
          type: 'bar',
          height: 250,
          toolbar: {
            show: false
          },
          animations: {
            enabled: true,
            easing: 'easeOutQuart',
            speed: 1200,
            animateGradually: {
              enabled: true,
              delay: 200
            },
            dynamicAnimation: {
              enabled: true,
              speed: 450
            }
          },
          dropShadow: {
            enabled: true,
            top: 2,
            left: 2,
            blur: 4,
            opacity: 0.1
          }
        },
        colors: ['#0c2f9d', '#e55d0a', '#10B981', '#F59E0B', '#EF4444'],
        plotOptions: {
          bar: {
            horizontal: false,
            columnWidth: '55%',
            endingShape: 'rounded',
            borderRadius: 8,
            distributed: false,
            dataLabels: {
              position: 'top'
            }
          }
        },
        dataLabels: {
          enabled: false
        },
        stroke: {
          show: true,
          width: 2,
          colors: ['transparent']
        },
        xaxis: {
          categories: chartData.categories,
          labels: {
            style: {
              colors: '#6B7280',
              fontSize: '12px',
              fontFamily: 'Inter, sans-serif'
            }
          },
          axisBorder: {
            show: false
          },
          axisTicks: {
            show: false
          }
        },
        yaxis: {
          labels: {
            style: {
              colors: '#6B7280',
              fontSize: '12px',
              fontFamily: 'Inter, sans-serif'
            },
            formatter: function(value) {
              return value.toLocaleString();
            }
          }
        },
        fill: {
          opacity: 1,
          type: 'gradient',
          gradient: {
            shade: 'light',
            type: 'vertical',
            shadeIntensity: 0.3,
            gradientToColors: undefined,
            inverseColors: true,
            opacityFrom: 1,
            opacityTo: 0.8,
            stops: [0, 50, 100]
          }
        },
        grid: {
          borderColor: '#E5E7EB',
          strokeDashArray: 4,
          xaxis: {
            lines: {
              show: false
            }
          },
          yaxis: {
            lines: {
              show: true
            }
          }
        },
        legend: {
          position: 'top',
          horizontalAlign: 'right',
          fontSize: '14px',
          fontFamily: 'Inter, sans-serif',
          fontWeight: 600
        },
        tooltip: {
          enabled: true,
          theme: 'light',
          style: {
            fontSize: '12px',
            fontFamily: 'Inter, sans-serif'
          },
          y: {
            formatter: function(value) {
              return value.toLocaleString();
            }
          },
          marker: {
            show: false
          }
        },
        states: {
          hover: {
            filter: {
              type: 'lighten',
              value: 0.1
            }
          },
          active: {
            filter: {
              type: 'darken',
              value: 0.1
            }
          }
        },
        responsive: [{
          breakpoint: 768,
          options: {
            chart: {
              height: 200
            },
            legend: {
              position: 'bottom'
            },
            plotOptions: {
              bar: {
                columnWidth: '70%'
              }
            }
          }
        }]
      };

      const chart = new ApexCharts(this.el, options);
      chart.render();
      
      // Add hover effects
      this.el.addEventListener('mouseenter', () => {
        this.el.style.transform = 'scale(1.02)';
        this.el.style.transition = 'transform 0.3s ease';
      });
      
      this.el.addEventListener('mouseleave', () => {
        this.el.style.transform = 'scale(1)';
      });
    }
  },

  LineChart: {
    mounted() {
      const chartData = JSON.parse(this.el.dataset.chartData);
      
      // Add entrance animation
      this.el.style.opacity = '0';
      this.el.style.transform = 'translateX(-20px)';
      
      setTimeout(() => {
        this.el.style.transition = 'all 0.8s cubic-bezier(0.4, 0, 0.2, 1)';
        this.el.style.opacity = '1';
        this.el.style.transform = 'translateX(0)';
      }, 200);
      
      const options = {
        series: chartData.series,
        chart: {
          type: 'line',
          height: 250,
          toolbar: {
            show: false
          },
          animations: {
            enabled: true,
            easing: 'easeOutQuart',
            speed: 1500,
            animateGradually: {
              enabled: true,
              delay: 300
            },
            dynamicAnimation: {
              enabled: true,
              speed: 500
            }
          },
          dropShadow: {
            enabled: true,
            top: 2,
            left: 2,
            blur: 4,
            opacity: 0.1
          }
        },
        colors: ['#0c2f9d', '#e55d0a', '#10B981'],
        stroke: {
          curve: 'smooth',
          width: 4,
          lineCap: 'round'
        },
        fill: {
          type: 'gradient',
          gradient: {
            shadeIntensity: 1,
            opacityFrom: 0.8,
            opacityTo: 0.2,
            stops: [0, 50, 100],
            colorStops: [
              {
                offset: 0,
                color: '#0c2f9d',
                opacity: 0.8
              },
              {
                offset: 50,
                color: '#e55d0a',
                opacity: 0.4
              },
              {
                offset: 100,
                color: '#10B981',
                opacity: 0.2
              }
            ]
          }
        },
        markers: {
          size: 6,
          strokeWidth: 3,
          strokeColors: '#ffffff',
          fillColors: ['#0c2f9d', '#e55d0a', '#10B981'],
          hover: {
            size: 8,
            sizeOffset: 2
          }
        },
        xaxis: {
          categories: chartData.categories,
          labels: {
            style: {
              colors: '#6B7280',
              fontSize: '12px',
              fontFamily: 'Inter, sans-serif'
            }
          },
          axisBorder: {
            show: false
          },
          axisTicks: {
            show: false
          }
        },
        yaxis: {
          labels: {
            style: {
              colors: '#6B7280',
              fontSize: '12px',
              fontFamily: 'Inter, sans-serif'
            },
            formatter: function(value) {
              return value.toLocaleString();
            }
          }
        },
        grid: {
          borderColor: '#E5E7EB',
          strokeDashArray: 4,
          xaxis: {
            lines: {
              show: false
            }
          },
          yaxis: {
            lines: {
              show: true
            }
          }
        },
        legend: {
          position: 'top',
          horizontalAlign: 'right',
          fontSize: '14px',
          fontFamily: 'Inter, sans-serif',
          fontWeight: 600
        },
        tooltip: {
          enabled: true,
          theme: 'light',
          style: {
            fontSize: '12px',
            fontFamily: 'Inter, sans-serif'
          },
          y: {
            formatter: function(value) {
              return value.toLocaleString();
            }
          },
          marker: {
            show: false
          }
        },
        states: {
          hover: {
            filter: {
              type: 'lighten',
              value: 0.1
            }
          },
          active: {
            filter: {
              type: 'darken',
              value: 0.1
            }
          }
        },
        responsive: [{
          breakpoint: 768,
          options: {
            chart: {
              height: 200
            },
            legend: {
              position: 'bottom'
            }
          }
        }]
      };

      const chart = new ApexCharts(this.el, options);
      chart.render();
      
      // Add hover effects
      this.el.addEventListener('mouseenter', () => {
        this.el.style.transform = 'scale(1.02)';
        this.el.style.transition = 'transform 0.3s ease';
      });
      
      this.el.addEventListener('mouseleave', () => {
        this.el.style.transform = 'scale(1)';
      });
    }
  },

  PieChart: {
    mounted() {
      const chartData = JSON.parse(this.el.dataset.chartData);
      
      // Add entrance animation
      this.el.style.opacity = '0';
      this.el.style.transform = 'scale(0.8) rotate(-10deg)';
      
      setTimeout(() => {
        this.el.style.transition = 'all 1s cubic-bezier(0.34, 1.56, 0.64, 1)';
        this.el.style.opacity = '1';
        this.el.style.transform = 'scale(1) rotate(0deg)';
      }, 300);
      
      const options = {
        series: chartData.map(item => item.value),
        chart: {
          type: 'pie',
          height: 200,
          animations: {
            enabled: true,
            easing: 'easeOutQuart',
            speed: 1000,
            animateGradually: {
              enabled: true,
              delay: 400
            },
            dynamicAnimation: {
              enabled: true,
              speed: 600
            }
          },
          dropShadow: {
            enabled: true,
            top: 2,
            left: 2,
            blur: 4,
            opacity: 0.1
          }
        },
        colors: chartData.map(item => item.color),
        labels: chartData.map(item => item.label),
        legend: {
          show: false
        },
        dataLabels: {
          enabled: false
        },
        stroke: {
          width: 3,
          colors: ['#ffffff']
        },
        plotOptions: {
          pie: {
            donut: {
              size: '65%',
              labels: {
                show: true,
                name: {
                  show: true,
                  fontSize: '16px',
                  fontFamily: 'Inter, sans-serif',
                  fontWeight: 600,
                  color: '#374151'
                },
                value: {
                  show: true,
                  fontSize: '24px',
                  fontFamily: 'Inter, sans-serif',
                  fontWeight: 700,
                  color: '#111827'
                },
                total: {
                  show: true,
                  label: 'Total',
                  fontSize: '14px',
                  fontFamily: 'Inter, sans-serif',
                  fontWeight: 600,
                  color: '#6B7280'
                }
              }
            },
            offsetY: 0
          }
        },
        tooltip: {
          enabled: true,
          theme: 'light',
          style: {
            fontSize: '12px',
            fontFamily: 'Inter, sans-serif'
          },
          y: {
            formatter: function(value, { series, seriesIndex, dataPointIndex, w }) {
              const total = series.reduce((a, b) => a + b, 0);
              const percentage = ((value / total) * 100).toFixed(1);
              return `${value} (${percentage}%)`;
            }
          },
          marker: {
            show: false
          }
        },
        states: {
          hover: {
            filter: {
              type: 'lighten',
              value: 0.1
            }
          },
          active: {
            filter: {
              type: 'darken',
              value: 0.1
            }
          }
        },
        responsive: [{
          breakpoint: 480,
          options: {
            chart: {
              height: 150
            }
          }
        }]
      };

      const chart = new ApexCharts(this.el, options);
      chart.render();
      
      // Add rotation animation on hover
      this.el.addEventListener('mouseenter', () => {
        this.el.style.transform = 'scale(1.05) rotate(5deg)';
        this.el.style.transition = 'transform 0.4s cubic-bezier(0.34, 1.56, 0.64, 1)';
      });
      
      this.el.addEventListener('mouseleave', () => {
        this.el.style.transform = 'scale(1) rotate(0deg)';
      });
    }
  }
};

export default ChartHooks; 