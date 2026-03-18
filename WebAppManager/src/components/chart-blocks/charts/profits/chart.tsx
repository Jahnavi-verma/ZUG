"use client";

import { useAtomValue } from "jotai";
import { VChart } from "@visactor/react-vchart";
import type { ILineChartSpec } from "@visactor/vchart"; // Changed to Line Spec
import { ticketChartDataAtom } from "@/lib/atoms";
import type { TicketMetric } from "@/types/types";

// Changed logic to return a Line Chart Spec
const generateSpec = (data: TicketMetric[]): ILineChartSpec => ({
  type: "line",
  color: ["#ef4444", "#22c55e"], // Red and Green (using Tailwind-style hex codes)
  data: [
    {
      id: "lineData",
      values: data,
    },
  ],
  xField: "date",
  yField: "count",
  seriesField: "type", // This creates the "Multiple Lines" (e.g., desktop vs mobile)
  padding: [20, 20, 20, 20],
  legends: {
    visible: true,
    orient: "bottom",
    item: { // Add this wrapper
      label: {
        style: {
          text: (datum: any) => { // Added :any to fix the second error
            if (datum === "created") return "Premium Collected";
            if (datum === "resolved") return "Claims Given";
            return datum;
          },
          fill: "#fff"
        }
      }
    }
  },
  // Smooth curves like the "monotone" type in Recharts
  line: {
    style: {
      curveType: "monotone",
      lineWidth: 3,
    },
  },
  // Adding dots/points (similar to dot={false} in your sample, set to true if you want them)
  point: {
    visible: false,
  },
  axes: [
    {
      orient: "left",
      grid: { visible: true, style: { lineDash: [4, 4] } }, // Recharts-style dashed grid
    },
    {
      orient: "bottom",
      label: { visible: true },
    },
  ],
  tooltip: {
    trigger: ["hover"],
  },
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
});

export default function Chart() {
  const ticketChartData = useAtomValue(ticketChartDataAtom);
  const spec = generateSpec(ticketChartData);
  
  return (
    <div className="w-full h-[400px]">
       {/* VChart will automatically scale to the div size */}
       <VChart spec={spec} />
    </div>
  );
}