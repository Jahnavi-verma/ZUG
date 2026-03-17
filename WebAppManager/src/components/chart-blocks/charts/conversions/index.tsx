"use client";

import { AlertCircle } from "lucide-react"; // Changed icon to Alert
import { profitData } from "@/data/profitData";
import { addThousandsSeparator } from "@/lib/utils";
import ChartTitle from "../../components/chart-title";
import Chart from "./chart";

export default function Conversions() {
  // 1. Sort the data to find the highest failure rates
  const sortedData = [...(profitData || [])].sort((a, b) => b.value - a.value);
  
  // 2. Take top 5 and calculate their average failure percentage
  const top5 = sortedData.slice(0, 5);
  const avgFailure = top5.length > 0 
    ? Math.round(top5.reduce((acc, curr) => acc + (curr.value || 0), 0) / top5.length)
    : 0;

  return (
    <section className="flex h-full flex-col gap-2">
      {/* Updated Title */}
      <ChartTitle title="Highest Failed Deliveries" icon={AlertCircle} />
      
      <Indicator value={avgFailure} />
      
      <div className="relative max-h-80 flex-grow">
        <Chart />
      </div>
    </section>
  );
}

function Indicator({ value }: { value: number }) {
  return (
    <div className="mt-3">
      <span className="mr-1 text-2xl font-medium">
        {value}%
      </span>
      <span className="text-muted-foreground/60">Avg. Failure Rate (Top 5)</span>
    </div>
  );
}