import { useState } from "react";
import type React from "react";
import { Check } from "lucide-react";
import type { Row, Field, FormDefinition } from "../types";
import { options } from "../forms";
import { Modal } from "./Modal";

export function EditForm({
  definition,
  close,
  complete,
}: {
  definition: FormDefinition;
  close: () => void;
  complete: () => Promise<void>;
}) {
  const [values, setValues] = useState<Row>(definition.initial);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");
  function change(field: Field, value: any) {
    const next = { ...values, [field.key]: value };
    setValues(definition.onChange?.(field.key, value, next) || next);
  }
  async function submit(e: React.FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError("");
    try {
      await definition.submit(values);
      await complete();
      close();
    } catch (e) {
      setError((e as Error).message);
    } finally {
      setBusy(false);
    }
  }
  return (
    <Modal
      title={definition.title}
      close={() => {
        if (!busy) close();
      }}
    >
      <form onSubmit={submit}>
        {definition.description && (
          <p className="form-description">{definition.description}</p>
        )}
        <div className="form-grid">
          {definition.fields
            .filter((field) => !field.visible || field.visible(values))
            .map((field) => (
              <label
                key={field.key}
                className={
                  ["textarea", "multi"].includes(field.type || "")
                    ? "span-two"
                    : ""
                }
              >
                <span>
                  {field.label}
                  {field.required !== false && <b className="required"> *</b>}
                </span>
                {field.options ? (
                  field.type === "multi" ? (
                    <select
                      multiple
                      value={(values[field.key] || []).map(String)}
                      onChange={(e) =>
                        change(
                          field,
                          [...e.target.selectedOptions].map((x) =>
                            Number(x.value),
                          ),
                        )
                      }
                      required={field.required !== false}
                      size={Math.min(5, Math.max(3, field.options.length))}
                    >
                      {field.options.map((o) => (
                        <option key={o.value} value={o.value}>
                          {o.label}
                        </option>
                      ))}
                    </select>
                  ) : (
                    <select
                      value={values[field.key] ?? ""}
                      onChange={(e) =>
                        change(
                          field,
                          field.type === "number"
                            ? Number(e.target.value)
                            : e.target.value,
                        )
                      }
                      required={field.required !== false}
                    >
                      <option value="">Chọn…</option>
                      {field.options.map((o) => (
                        <option key={o.value} value={o.value}>
                          {o.label}
                        </option>
                      ))}
                    </select>
                  )
                ) : field.type === "textarea" ? (
                  <textarea
                    rows={3}
                    value={values[field.key] || ""}
                    onChange={(e) => change(field, e.target.value)}
                    required={field.required !== false}
                    maxLength={2000}
                  />
                ) : field.type === "checkbox" ? (
                  <input
                    type="checkbox"
                    checked={!!values[field.key]}
                    onChange={(e) => change(field, e.target.checked)}
                  />
                ) : (
                  <input
                    type={field.type || "text"}
                    value={values[field.key] ?? ""}
                    onChange={(e) =>
                      change(
                        field,
                        field.type === "number"
                          ? Number(e.target.value)
                          : e.target.value,
                      )
                    }
                    min={field.min ?? (field.type === "number" ? 0 : undefined)}
                    max={
                      field.max ??
                      (field.type === "number" ? 1_000_000_000 : undefined)
                    }
                    step={
                      field.step || (field.type === "number" ? "1" : undefined)
                    }
                    required={field.required !== false}
                    maxLength={field.type === "password" ? 128 : 500}
                    autoComplete={
                      field.type === "password" ? "new-password" : "off"
                    }
                  />
                )}
                {field.hint && <small>{field.hint}</small>}
              </label>
            ))}
        </div>
        {error && (
          <div className="error" role="alert">
            {error}
          </div>
        )}
        <footer>
          <button
            type="button"
            className="button secondary"
            onClick={close}
            disabled={busy}
          >
            Hủy
          </button>
          <button className="button" disabled={busy}>
            {busy ? (
              "Đang lưu…"
            ) : (
              <>
                <Check size={16} />
                Lưu thông tin
              </>
            )}
          </button>
        </footer>
      </form>
    </Modal>
  );
}
