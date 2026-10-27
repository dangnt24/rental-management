import type { Row, Option, Field } from "./types";

export const options = (rows: Row[], label: (r: Row) => string): Option[] =>
  rows.map((x) => ({ value: x.id, label: label(x) }));

export const amountField = (key: string, label: string): Field => ({
  key,
  label,
  type: "number",
  min: 0,
  step: "1",
});

export const dateField = (key: string, label: string): Field => ({
  key,
  label,
  type: "date",
});
