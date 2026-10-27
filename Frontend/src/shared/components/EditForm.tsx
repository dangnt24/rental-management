import { Fragment, useState } from "react";
import type React from "react";
import { Check, RotateCcw, X } from "lucide-react";
import { useInteractionGuard, useUnsavedChanges } from "../InteractionGuard";
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
  const { leave, confirm } = useInteractionGuard();
  const dirty = JSON.stringify(values) !== JSON.stringify(definition.initial);
  useUnsavedChanges(dirty, busy);
  async function requestClose() {
    if (!busy && (await leave())) close();
  }
  function change(field: Field, value: any) {
    const next = { ...values, [field.key]: value };
    setValues(definition.onChange?.(field.key, value, next) || next);
  }
  async function submit(e: React.FormEvent) {
    e.preventDefault();
    if (busy) return;
    if (definition.confirmation && !(await confirm(definition.confirmation)))
      return;
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
      wide={definition.wide}
      close={() => {
        void requestClose();
      }}
    >
      <form onSubmit={submit}>
        {definition.description && (
          <p className="form-description">{definition.description}</p>
        )}
        <div className="form-grid">
          {definition.fields
            .filter((field) => !field.visible || field.visible(values))
            .map((field) => {
              const Label = field.type === "checklist" ? "div" : "label";
              return (
                <Fragment key={field.key}>
                  {field.section && (
                    <h3 className="form-section-heading span-two">
                      {field.section}
                    </h3>
                  )}
                  <Label
                    key={field.key}
                    className={
                      ["textarea", "multi", "checklist"].includes(
                        field.type || "",
                      )
                        ? "span-two"
                        : ""
                    }
                  >
                    <span>
                      {field.label}
                      {field.required !== false && (
                        <b className="required"> *</b>
                      )}
                    </span>
                    {field.options ? (
                      field.type === "checklist" ? (
                        <div
                          className="form-checklist"
                          role="group"
                          aria-label={field.label}
                        >
                          {field.options.map((option) => {
                            const selected = (values[field.key] || []).includes(
                              option.value,
                            );
                            return (
                              <button
                                type="button"
                                role="checkbox"
                                aria-checked={selected}
                                className={selected ? "selected" : ""}
                                key={option.value}
                                onClick={() =>
                                  change(
                                    field,
                                    selected
                                      ? values[field.key].filter(
                                          (value: string) =>
                                            value !== option.value,
                                        )
                                      : [
                                          ...(values[field.key] || []),
                                          option.value,
                                        ],
                                  )
                                }
                              >
                                <span>
                                  <Check size={14} />
                                </span>
                                {option.label}
                              </button>
                            );
                          })}
                        </div>
                      ) : field.type === "multi" ? (
                        <select
                          multiple
                          value={(values[field.key] || []).map(String)}
                          onChange={(e) =>
                            change(
                              field,
                              [...e.target.selectedOptions].map((x) =>
                                field.valueType === "string"
                                  ? x.value
                                  : Number(x.value),
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
                              ? e.target.value === "" &&
                                field.required === false
                                ? ""
                                : Number(e.target.value)
                              : e.target.value,
                          )
                        }
                        min={
                          field.min ?? (field.type === "number" ? 0 : undefined)
                        }
                        max={
                          field.max ??
                          (field.type === "number" ? 1_000_000_000 : undefined)
                        }
                        step={
                          field.step ||
                          (field.type === "number" ? "1" : undefined)
                        }
                        required={field.required !== false}
                        maxLength={field.type === "password" ? 128 : 500}
                        autoComplete={
                          field.type === "password" ? "new-password" : "off"
                        }
                      />
                    )}
                    {field.hint && <small>{field.hint}</small>}
                  </Label>
                </Fragment>
              );
            })}
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
            onClick={() => {
              void requestClose();
            }}
            disabled={busy}
          >
            <X size={16} />
            Hủy
          </button>
          {definition.fields.length > 0 && (
            <button
              type="button"
              className="button secondary"
              disabled={busy || !dirty}
              onClick={async () => {
                if (
                  await confirm({
                    title: "Đặt lại biểu mẫu?",
                    message:
                      "Các thay đổi đang nhập sẽ bị xóa và biểu mẫu trở về dữ liệu ban đầu.",
                    confirmLabel: "Đặt lại",
                    danger: true,
                  })
                ) {
                  setValues(definition.initial);
                  setError("");
                }
              }}
            >
              <RotateCcw size={16} />
              Đặt lại
            </button>
          )}
          <button className="button" disabled={busy}>
            {busy ? (
              "Đang lưu…"
            ) : (
              <>
                <Check size={16} />
                {definition.confirmation?.confirmLabel || "Lưu thông tin"}
              </>
            )}
          </button>
        </footer>
      </form>
    </Modal>
  );
}
