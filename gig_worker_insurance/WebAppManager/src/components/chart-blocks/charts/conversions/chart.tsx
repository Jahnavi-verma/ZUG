"use client";

import { VChart } from "@visactor/react-vchart";
import type { ICirclePackingChartSpec } from "@visactor/vchart";
import { profitData } from "@/data/profitData"; // Assuming your district data is here
import { addThousandsSeparator } from "@/lib/utils";

// 1. Sort and take Top 5 districts
const top5Districts = [...profitData]
  .sort((a, b) => b.value - a.value)
  .slice(0, 5);

const spec: ICirclePackingChartSpec = {
  type: "circlePacking",
  data: [
    {
      id: "data",
      values: top5Districts,
    },
  ],
  categoryField: "name",
  valueField: "value",
  color: ["#3161F8", "#60C2FB", "#22c55e", "#ffcc00", "#8b5cf6"], // Your palette
  
  drill: false, // Set to false since we only want Top 5
  padding: 10,
  layoutPadding: 15, // Adds breathing room between bubbles

  // Inside chart.tsx spec
label: {
  visible: true,
  style: {
    fill: "white",
    fontWeight: 'bold',
    // Adds the % sign to the bubble text
    text: (d: any) => `${d.name}\n${d.value}%`, 
    fontSize: (d: any) => Math.max(d.radius / 5, 10),
    lineHeight: 1.2,
    textAlign: 'center',
    textBaseline: 'middle',
  },
},
tooltip: {
  trigger: ["click", "hover"],
  dimension: {
    content: {
      key: (d: any) => d?.name,
      value: (d: any) => `${d?.value}% Failed Deliveries`,
    },
  },
},

  legends: [
      {
        visible: true,
        orient: "top",
        position: "start",
        item: { // Add this wrapper
          label: {
            style: {
              fill: "#ccc",
            },
          },
        },
      },
    ],
  crosshair: {
    xField: {
      visible: true,
      line: {
        type: 'line',
        style: {
          lineDash: [4, 4],
          lineWidth: 2,
          stroke: '#cbcbcb',
        }
      }
    }
  },
};

export default function Chart() {
  return (
    <div className="h-full w-full">
      <VChart spec={spec} />
    </div>
  );
}