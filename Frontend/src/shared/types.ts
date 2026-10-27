import type { ReactNode } from "react";
import { options } from "./forms";

export type Row = Record<string, any>;

export type User = {
  id: number;
  username: string;
  fullName: string;
  role: "Owner" | "Manager" | "Tenant";
};

export type Page =
  | "overview"
  | "rooms"
  | "tenants"
  | "contracts"
  | "billing"
  | "payments"
  | "incidents"
  | "settings";

export type Option = { value: string | number; label: string };

export type Field = {
  key: string;
  label: string;
  type?: string;
  options?: Option[];
  required?: boolean;
  min?: number;
  max?: number;
  step?: string;
  hint?: string;
  visible?: (values: Row) => boolean;
};

export type FormDefinition = {
  title: string;
  description?: string;
  fields: Field[];
  initial: Row;
  submit: (values: Row) => Promise<unknown>;
  onChange?: (key: string, value: any, values: Row) => Row;
};

export type Column = { label: string; cell: (row: Row) => ReactNode };
