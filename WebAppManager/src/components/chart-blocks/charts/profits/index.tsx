"use client";

import { useAtomValue } from "jotai";
import { WalletCards } from "lucide-react"; 
import { ticketChartDataAtom } from "@/lib/atoms";
import type { TicketMetric } from "@/types/types";
import ChartTitle from "../../components/chart-title";
import Chart from "./chart";
import { DatePickerWithRange } from "./components/date-range-picker";
import MetricCard from "./components/metric-card";

// Safe calculation function
const calMetricCardValue = (
  data: TicketMetric[] | undefined,
  type: string,
) => {
  if (!data || !Array.isArray(data)) return 0;

  // Filter based on the 'type' string defined in your Atom
  const filteredData = data.filter((item) => item.type === type);
  
  if (filteredData.length === 0) return 0;

  const total = filteredData.reduce((acc, curr) => acc + (curr.count || 0), 0);
  return Math.round(total / filteredData.length);
};

export default function ProfitsGenerated() {
  const ticketChartData = useAtomValue(ticketChartDataAtom);
  
  // 1. Pass the correct data (ticketChartData)
  // 2. Use the exact strings from your Atom mapping
  const avgPremium = calMetricCardValue(ticketChartData, "Premium Collected");
  const avgClaims = calMetricCardValue(ticketChartData, "Claims Given");

  return (
    <section className="flex h-full flex-col gap-2">
      <div className="flex flex-wrap items-start justify-between gap-4">
        <ChartTitle title="Insurance Overview" icon={WalletCards} />
        <DatePickerWithRange className="" />
      </div>
      <div className="flex flex-wrap">
        <div className="my-4 flex w-52 shrink-0 flex-col justify-center gap-6">
          <MetricCard
            title="Avg. Premium Collected"
            value={avgPremium}
            color="#22c55e" 
          />
          <MetricCard
            title="Avg. Claims Given"
            value={avgClaims}
            color="#ef4444" 
          />
        </div>
        <div className="relative h-96 min-w-[320px] flex-1">
          <Chart />
        </div>
      </div>
    </section>
  );
}
