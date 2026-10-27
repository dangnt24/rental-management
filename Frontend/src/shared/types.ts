import type { ReactNode } from "react";
import { options } from "./forms";

export type Row = Record<string, any>;

export type User = {
  id: number;
  username: string;
  fullName: string;
  role: "Owner" | "Manager" | "Tenant";
  email?: string;
  phone?: string;
  avatarUrl?: string | null;
};

export type Page =
  | "overview"
  | "rooms"
  | "tenants"
  | "contracts"
  | "billing"
  | "payments"
  | "incidents"
  | "accounts"
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
  section?: string;
  valueType?: "number" | "string";
  visible?: (values: Row) => boolean;
};

export type FormDefinition = {
  title: string;
  wide?: boolean;
  description?: string;
  confirmation?: {
    title: string;
    message: string;
    confirmLabel?: string;
    danger?: boolean;
  };
  fields: Field[];
  initial: Row;
  submit: (values: Row) => Promise<unknown>;
  onChange?: (key: string, value: any, values: Row) => Row;
};

export type Column = { label: string; cell: (row: Row) => ReactNode };
