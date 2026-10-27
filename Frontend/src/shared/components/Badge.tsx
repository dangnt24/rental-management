import { labels } from "../labels";

export function Badge({ value }: { value: string }) {
  return (
    <span className={"badge " + value.toLowerCase()}>
      <i />
      {labels[value] || value}
    </span>
  );
}
