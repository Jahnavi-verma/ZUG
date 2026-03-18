import { addDays, endOfDay, isWithinInterval, startOfDay } from "date-fns";
import { atom } from "jotai";
import type { DateRange } from "react-day-picker";
import { averageTicketsCreated } from "@/data/profits";
import type { TicketMetric } from "@/types/types";

const defaultStartDate = new Date(2023, 11, 18);

export const dateRangeAtom = atom<DateRange | undefined>({
  from: defaultStartDate,
  to: addDays(defaultStartDate, 6),
});

export const ticketChartDataAtom = atom((get) => {
  const dateRange = get(dateRangeAtom);

  if (!dateRange?.from || !dateRange?.to) return [];

  const startDate = startOfDay(dateRange.from);
  const endDate = endOfDay(dateRange.to);

  return averageTicketsCreated
    .filter((item) => {
      const [year, month, day] = item.date.split("-").map(Number);
      const date = new Date(year, month - 1, day);
      return isWithinInterval(date, { start: startDate, end: endDate });
    })
    .flatMap((item) => {
      // CHANGED: Renamed 'type' values to the business labels
      const res: TicketMetric[] = [
        {
          date: item.date,
          type: "Claims Given",      // was "resolved"
          count: item.resolved,
        },
        {
          date: item.date,
          type: "Premium Collected", // was "created"
          count: item.created,
        },
      ];
      return res;
    });
});